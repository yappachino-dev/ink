// Package migrations embeds the goose SQL migrations so they ship inside the
// compiled binary (auto-migration on boot) and are available to the migrate
// CLI without access to the source tree.
package migrations

import "embed"

//go:embed *.sql
var FS embed.FS
