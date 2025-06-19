module gpgToRCW

go 1.24.4

require (
	github.com/rwinkhart/go-boilerplate v0.1.0
	github.com/rwinkhart/libmutton v0.3.2-0.20250619221323-1c0671354862
	github.com/rwinkhart/rcw v0.2.1
)

require (
	golang.org/x/crypto v0.39.0 // indirect
	golang.org/x/sys v0.33.0 // indirect
	golang.org/x/term v0.32.0 // indirect
)

replace golang.org/x/sys => github.com/rwinkhart/sys-freebsd-13-xucred v0.33.0

replace github.com/Microsoft/go-winio => github.com/rwinkhart/go-winio-easy-pipe-handles v0.0.0-20250407031321-96994a0e8410
