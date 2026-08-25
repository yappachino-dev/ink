package database

import "time"

// Bridges between optional timestamptz columns (*time.Time in sqlc output)
// and the domain convention where a zero time.Time means "absent".

func FromNullTime(t *time.Time) time.Time {
	if t == nil {
		return time.Time{}
	}
	return *t
}

func ToNullTime(t time.Time) *time.Time {
	if t.IsZero() {
		return nil
	}
	return &t
}
