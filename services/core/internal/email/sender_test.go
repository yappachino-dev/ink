package email

import (
	"bufio"
	"net"
	"strings"
	"testing"

	"github.com/yappachino-dev/ink/services/core/internal/config"
)

// fakeSMTP speaks just enough of the protocol for net/smtp's SendMail:
// greeting, EHLO (+AUTH PLAIN advertisement), MAIL FROM/RCPT TO/DATA/QUIT.
type fakeSMTP struct {
	t        *testing.T
	listener net.Listener

	mailFrom string
	rcptTo   string
	data     string
}

func startFakeSMTP(t *testing.T) *fakeSMTP {
	t.Helper()
	f := &fakeSMTP{t: t}
	l, err := net.Listen("tcp", "localhost:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}
	f.listener = l
	t.Cleanup(func() { _ = l.Close() })

	go f.serve()
	return f
}

func (f *fakeSMTP) serve() {
	conn, err := f.listener.Accept()
	if err != nil {
		return
	}
	defer conn.Close()

	write := func(s string) {
		if _, err := conn.Write([]byte(s)); err != nil {
			panic(err)
		}
	}
	r := bufio.NewReader(conn)

	write("220 fake ESMTP\r\n")
	for {
		line, err := r.ReadString('\n')
		if err != nil {
			return
		}
		raw := strings.TrimSpace(line)
		cmd := strings.ToUpper(raw)
		switch {
		case strings.HasPrefix(cmd, "EHLO"):
			// Advertise AUTH PLAIN so smtp.PlainAuth proceeds on localhost.
			write("250-fake\r\n250-AUTH PLAIN\r\n250 OK\r\n")
		case strings.HasPrefix(cmd, "AUTH"):
			f.t.Logf("auth line received (%d bytes)", len(cmd))
			write("235 authenticated\r\n")
		case strings.HasPrefix(cmd, "MAIL FROM:"):
			f.mailFrom = strings.Trim(strings.TrimPrefix(raw[len("MAIL FROM:"):], " "), "<>")
			write("250 OK\r\n")
		case strings.HasPrefix(cmd, "RCPT TO:"):
			f.rcptTo = strings.Trim(strings.TrimPrefix(raw[len("RCPT TO:"):], " "), "<>")
			write("250 OK\r\n")
		case cmd == "DATA":
			write("354 go ahead\r\n")
			var body strings.Builder
			for {
				l2, err := r.ReadString('\n')
				if err != nil {
					return
				}
				if strings.TrimSpace(l2) == "." {
					break
				}
				body.WriteString(l2)
			}
			f.data = body.String()
			write("250 OK queued\r\n")
		case cmd == "QUIT":
			write("221 bye\r\n")
			return
		default:
			write("502 not implemented\r\n")
		}
	}
}

func TestSendVerificationCodeDeliversFormattedMessage(t *testing.T) {
	f := startFakeSMTP(t)
	host, port, _ := net.SplitHostPort(f.listener.Addr().String())

	s := NewSender(config.SMTP{
		Host:     host,
		Port:     port,
		User:     "ink",
		Password: "secret",
		From:     "ink@localhost",
	})
	if err := s.SendVerificationCode("user@example.com", "123456"); err != nil {
		t.Fatalf("send: %v", err)
	}

	// Note: the envelope sender is SMTP user; cfg.From lands in the header.
	if f.mailFrom != "ink" || f.rcptTo != "user@example.com" {
		t.Fatalf("envelope mismatch: from=%q to=%q", f.mailFrom, f.rcptTo)
	}
	for _, want := range []string{
		"From: ink@localhost",
		"To: user@example.com",
		"Subject:",
		"123456",
		"Content-Type: text/html",
	} {
		if !strings.Contains(f.data, want) {
			t.Errorf("message missing %q", want)
		}
	}
}
