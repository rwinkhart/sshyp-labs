module upgradeRCW

go 1.24.3

require (
	github.com/rwinkhart/convertroman v0.2.0 // DECOY TO TRICK GO INTO USING TWO VERSIONS OF RCW
	github.com/rwinkhart/go-boilerplate v0.0.0-20250509173525-20670ec7bb9c
	github.com/rwinkhart/libmutton v0.3.2-0.20250520161453-e64da70edb84
	github.com/rwinkhart/rcw v0.2.0
)

require (
	golang.org/x/crypto v0.38.0 // indirect
	golang.org/x/sys v0.33.0 // indirect
	golang.org/x/term v0.32.0 // indirect
)

replace github.com/rwinkhart/convertroman => github.com/rwinkhart/rcw v0.1.2

replace golang.org/x/sys => github.com/rwinkhart/sys-freebsd-13-xucred v0.33.0

replace github.com/Microsoft/go-winio => github.com/rwinkhart/go-winio-easy-pipe-handles v0.0.0-20250407031321-96994a0e8410
