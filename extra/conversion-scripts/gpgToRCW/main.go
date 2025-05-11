package main

import (
	"bytes"
	"fmt"
	"os"
	"strings"

	"github.com/rwinkhart/go-boilerplate/back"
	"github.com/rwinkhart/go-boilerplate/front"
	"github.com/rwinkhart/libmutton/core"
	"github.com/rwinkhart/libmutton/sync"
	"github.com/rwinkhart/rcw/wrappers"
)

func main() {
	// get info from user
	var rcwPassphrase []byte
	for {
		rcwPassphrase = front.InputHidden("RCW passphrase:")
		if !bytes.Equal(rcwPassphrase, front.InputHidden("Confirm RCW passphrase:")) {
			fmt.Println(back.AnsiError + "Passphrases do not match" + back.AnsiReset)
			continue
		}
		break
	}

	// decrypt all GPG-encrypted entries to the output directory
	fmt.Print("\nRe-encrypting entries. Please wait; do not force close this process.\n\nGPG may prompt you for a passphrase for decryption.\n\n")
	var outputDir = core.EntryRoot + "-new"
	entries, folders := sync.WalkEntryDir()
	for _, folder := range folders {
		err := os.MkdirAll(outputDir+strings.ReplaceAll(folder, "/", core.PathSeparator), 0700)
		if err != nil {
			back.PrintError("Failed to create directory: "+err.Error(), back.ErrorWrite, true)
		}
	}
	var decLines []string
	for _, entry := range entries {
		decLines = decryptGPG(core.TargetLocationFormat(entry))
		encBytes := wrappers.Encrypt([]byte(strings.Join(decLines, "\n")), rcwPassphrase)
		err := os.WriteFile(outputDir+strings.ReplaceAll(entry, "/", core.PathSeparator), encBytes, 0600)
		if err != nil {
			back.PrintError("Failed to write to file: "+err.Error(), back.ErrorWrite, true)
		}
	}

	// swap the new directory with the old one
	err := os.Rename(core.EntryRoot, core.EntryRoot+"-old")
	if err != nil {
		back.PrintError("Failed to rename old directory: "+err.Error(), back.ErrorWrite, true)
	}
	err = os.Rename(outputDir, core.EntryRoot)
	if err != nil {
		back.PrintError("Failed to rename new directory: "+err.Error(), back.ErrorWrite, true)
	}
}
