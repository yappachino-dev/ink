package ratelimit

import (
	"fmt"
	"testing"
	"time"
)

func TestLimiter_AllowsUpToLimit(t *testing.T) {
	l := New(3, time.Minute)

	for i := 0; i < 3; i++ {
		if !l.Allow("a") {
			t.Fatalf("request %d should be allowed", i+1)
		}
	}

	if l.Allow("a") {
		t.Fatal("request beyond limit should be denied")
	}
}

func TestLimiter_KeysAreIndependent(t *testing.T) {
	l := New(1, time.Minute)

	if !l.Allow("a") {
		t.Fatal("first request for key a should be allowed")
	}
	if !l.Allow("b") {
		t.Fatal("first request for key b should be allowed")
	}
	if l.Allow("a") {
		t.Fatal("second request for key a should be denied")
	}
}

func TestLimiter_WindowReset(t *testing.T) {
	l := New(1, 10*time.Millisecond)

	if !l.Allow("a") {
		t.Fatal("first request should be allowed")
	}
	if l.Allow("a") {
		t.Fatal("second request inside window should be denied")
	}

	time.Sleep(15 * time.Millisecond)

	if !l.Allow("a") {
		t.Fatal("request after window should be allowed")
	}
}

func TestLimiter_NeverExceedsHardBucketLimit(t *testing.T) {
	l := New(1, time.Hour)

	for i := 0; i < maxBuckets+100; i++ {
		l.Allow(fmt.Sprintf("key-%d", i))
	}

	l.mu.Lock()
	defer l.mu.Unlock()
	if len(l.buckets) > maxBuckets {
		t.Fatalf("bucket count exceeded hard limit: %d", len(l.buckets))
	}
}

func TestLimiter_EvictsStaleBuckets(t *testing.T) {
	l := New(1, time.Millisecond)

	// Fill past the eviction threshold with stale buckets.
	for i := 0; i < 10_100; i++ {
		l.Allow(string(rune(i%256)) + time.Now().String())
	}

	time.Sleep(5 * time.Millisecond)
	l.Allow("trigger-cleanup")

	l.mu.Lock()
	defer l.mu.Unlock()

	if len(l.buckets) > 10_000 {
		t.Fatalf("stale buckets should be evicted, got %d", len(l.buckets))
	}
}
