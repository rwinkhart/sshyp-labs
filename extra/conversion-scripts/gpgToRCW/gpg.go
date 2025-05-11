package main

import (
	"os/exec"
	"strings"

	"github.com/rwinkhart/go-boilerplate/back"
	"github.com/rwinkhart/libmutton/core"
)

// decryptGPG decrypts a GPG-encrypted file and returns the contents as a slice of (trimmed) strings.
func decryptGPG(targetLocation string) []string {
	cmd := exec.Command("gpg", "--pinentry-mode", "loopback", "-q", "-d", targetLocation)
	output, err := cmd.Output()
	if err != nil {
		back.PrintError("Failed to decrypt \""+targetLocation+"\" - Ensure it is a valid GPG-encrypted file and that you entered your passphrase correctly", core.ErrorDecryption, true)
	}
	return strings.Split(string(output), "\n")
}
