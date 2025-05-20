package main

import (
	"bytes"
	"fmt"
	"os"
	"strings"

	oldwrap "github.com/rwinkhart/convertroman/wrappers"
	newwrap "github.com/rwinkhart/rcw/wrappers"

	"github.com/rwinkhart/go-boilerplate/back"
	"github.com/rwinkhart/go-boilerplate/front"
	"github.com/rwinkhart/libmutton/global"
	"github.com/rwinkhart/libmutton/synccommon"
)

func main() {
	// get info from user
	var oldRCWPassphrase, newRCWPassphrase []byte
	for {
		oldRCWPassphrase = front.InputHidden("RCW passphrase:")
		if !bytes.Equal(oldRCWPassphrase, front.InputHidden("Confirm RCW passphrase:")) {
			fmt.Println(back.AnsiError + "Passphrases do not match" + back.AnsiReset)
			continue
		}
		break
	}
	for {
		newRCWPassphrase = front.InputHidden("RCW passphrase:")
		if !bytes.Equal(newRCWPassphrase, front.InputHidden("Confirm RCW passphrase:")) {
			fmt.Println(back.AnsiError + "Passphrases do not match" + back.AnsiReset)
			continue
		}
		break
	}

	// convert the entries
	fmt.Print("\nRe-encrypting entries. Please wait; do not force close this process.\n\n")
	var outputDir = global.EntryRoot + "-new"
	entries, folders := synccommon.WalkEntryDir()
	for _, folder := range folders {
		err := os.MkdirAll(outputDir+strings.ReplaceAll(folder, "/", global.PathSeparator), 0700)
		if err != nil {
			back.PrintError("Failed to create directory: "+err.Error(), back.ErrorWrite, true)
		}
	}
	for _, entry := range entries {
		oldEncBytes, err := os.ReadFile(global.TargetLocationFormat(entry))
		if err != nil {
			back.PrintError("Failed to read file: "+err.Error(), back.ErrorRead, true)
		}
		decBytes, err := oldwrap.Decrypt(oldEncBytes, oldRCWPassphrase)
		if err != nil {
			back.PrintError("Failed to decrypt file: "+err.Error(), back.ErrorWrite, true)
		}
		newEncBytes := newwrap.Encrypt(decBytes, newRCWPassphrase)
		err = os.WriteFile(outputDir+strings.ReplaceAll(entry, "/", global.PathSeparator), newEncBytes, 0600)
		if err != nil {
			back.PrintError("Failed to write to file: "+err.Error(), back.ErrorWrite, true)
		}
	}

	// swap the new directory with the old one
	err := os.Rename(global.EntryRoot, global.EntryRoot+"-old")
	if err != nil {
		back.PrintError("Failed to rename old directory: "+err.Error(), back.ErrorWrite, true)
	}
	err = os.Rename(outputDir, global.EntryRoot)
	if err != nil {
		back.PrintError("Failed to rename new directory: "+err.Error(), back.ErrorWrite, true)
	}
}
