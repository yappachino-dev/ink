package database

// BatchResults matches the Exec surface of sqlc-generated *BatchResults types
// (which close the underlying pgx batch themselves once drained).
type BatchResults interface {
	Exec(f func(index int, err error))
}

// ExecBatch drains a sqlc batch, returning the first error encountered while
// keeping all remaining queries executing.
func ExecBatch(results BatchResults) error {
	var batchErr error
	results.Exec(func(_ int, err error) {
		if err != nil && batchErr == nil {
			batchErr = err
		}
	})

	return batchErr
}
