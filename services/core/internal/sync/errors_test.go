package sync

import (
	"strings"
	"testing"

	"github.com/google/uuid"
)

func TestFormatUUIDsTruncates(t *testing.T) {
	ids := make([]uuid.UUID, 0, 25)
	for i := 0; i < 25; i++ {
		ids = append(ids, uuid.New())
	}

	got := formatUUIDs(ids)

	// Five ids spelled out, then an explicit count of the remainder.
	if !strings.HasSuffix(got, "(and 20 more)") {
		t.Fatalf("expected a truncation marker, got %q", got)
	}
	// A UUID has 4 hyphens, so exactly 5 values means 20 of them.
	if strings.Count(got, "-") != 5*4 {
		t.Fatalf("expected exactly 5 uuid values in %q", got)
	}
}

func TestFormatUUIDsShortListIsUnchanged(t *testing.T) {
	ids := []uuid.UUID{
		uuid.MustParse("00000000-0000-7000-8000-000000000001"),
		uuid.MustParse("00000000-0000-7000-8000-000000000002"),
	}

	got := formatUUIDs(ids)

	if strings.Contains(got, "more") {
		t.Fatalf("a short list must not be truncated, got %q", got)
	}
	if got != ids[0].String()+", "+ids[1].String() {
		t.Fatalf("unexpected formatting: %q", got)
	}
}

func TestFormatUUIDsEmpty(t *testing.T) {
	if got := formatUUIDs(nil); got != "" {
		t.Fatalf("expected empty string, got %q", got)
	}
}

func TestOwnershipConflictErrorBoundsIDs(t *testing.T) {
	ids := make([]uuid.UUID, 0, 50)
	for i := 0; i < 50; i++ {
		ids = append(ids, uuid.New())
	}

	err := (&OwnershipConflictError{Entity: "project", IDs: ids}).Error()

	// A hostile batch must not be able to inflate the response or the logs.
	if len(err) > 400 {
		t.Fatalf("error message grew to %d bytes; it must stay bounded", len(err))
	}
	if !strings.Contains(err, "(and 45 more)") {
		t.Fatalf("expected a truncation marker, got %q", err)
	}
}
