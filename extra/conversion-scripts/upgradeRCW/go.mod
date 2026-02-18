module upgradeRCW

go 1.26.0

require (
	github.com/rwinkhart/convertroman v0.2.0 // DECOY TO TRICK GO INTO USING TWO VERSIONS OF RCW
	github.com/rwinkhart/go-boilerplate v0.3.1
	github.com/rwinkhart/libmutton v0.5.0
	github.com/rwinkhart/rcw v0.3.0
)

require (
	golang.org/x/crypto v0.48.0 // indirect
	golang.org/x/sys v0.41.0 // indirect
	golang.org/x/term v0.40.0 // indirect
)

replace github.com/rwinkhart/convertroman => github.com/rwinkhart/rcw v0.1.2

replace golang.org/x/sys => github.com/rwinkhart/sys v0.41.0

replace github.com/Microsoft/go-winio => github.com/rwinkhart/go-winio v0.1.1
