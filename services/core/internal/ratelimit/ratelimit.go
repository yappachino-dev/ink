package ratelimit

import (
	"sync"
	"time"
)

// Limiter is a fixed-window rate limiter keyed by arbitrary strings
// (e.g. peer IP or account email). Intentionally in-memory: it protects a
// single replica; revisit when running multiple instances.
const maxBuckets = 10_000

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
		if !ok && len(l.buckets) >= maxBuckets {
			l.evictForInsert(now)
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

// evictForInsert removes expired buckets first, then the oldest bucket if the
// map is still full. The caller holds l.mu.
func (l *Limiter) evictForInsert(now time.Time) {
	for k, v := range l.buckets {
		if now.Sub(v.windowStart) >= l.window {
			delete(l.buckets, k)
		}
	}

	if len(l.buckets) < maxBuckets {
		return
	}

	var oldestKey string
	var oldestStart time.Time
	for k, v := range l.buckets {
		if oldestStart.IsZero() || v.windowStart.Before(oldestStart) {
			oldestKey = k
			oldestStart = v.windowStart
		}
	}
	delete(l.buckets, oldestKey)
}
