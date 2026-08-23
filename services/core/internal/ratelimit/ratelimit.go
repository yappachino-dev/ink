package ratelimit

import (
	"sync"
	"time"
)

// Limiter is a fixed-window rate limiter keyed by arbitrary strings
// (e.g. peer IP or account email). Intentionally in-memory: it protects a
// single replica; revisit when running multiple instances.
type Limiter struct {
	mu     sync.Mutex
	limit  int
	window time.Duration

	buckets map[string]*bucket
}

type bucket struct {
	windowStart time.Time
	count       int
}

func New(limit int, window time.Duration) *Limiter {
	return &Limiter{
		limit:   limit,
		window:  window,
		buckets: make(map[string]*bucket),
	}
}

// Allow reports whether the key may proceed within the current window.
func (l *Limiter) Allow(key string) bool {
	now := time.Now()

	l.mu.Lock()
	defer l.mu.Unlock()

	b, ok := l.buckets[key]
	if !ok || now.Sub(b.windowStart) >= l.window {
		// Lazy eviction of stale buckets to keep the map bounded.
		if len(l.buckets) > 10_000 {
			for k, v := range l.buckets {
				if now.Sub(v.windowStart) >= l.window {
					delete(l.buckets, k)
				}
			}
		}

		l.buckets[key] = &bucket{windowStart: now, count: 1}
		return true
	}

	if b.count >= l.limit {
		return false
	}

	b.count++
	return true
}
