package main

import (
	"bytes"
	"fmt"
	"os"
	"strings"

	"github.com/rwinkhart/go-boilerplate/back"
	"github.com/rwinkhart/go-boilerplate/front"
	"github.com/rwinkhart/go-boilerplate/other"
	"github.com/rwinkhart/libmutton/global"
	"github.com/rwinkhart/libmutton/synccommon"
	"github.com/rwinkhart/rcw/wrappers"
)

func main() {
	// get info from user
	var rcwPassphrase []byte
	for {
		rcwPassphrase = front.InputSecret("RCW passphrase:")
		if !bytes.Equal(rcwPassphrase, front.InputSecret("Confirm RCW passphrase:")) {
			fmt.Println(back.AnsiError + "Passphrases do not match" + back.AnsiReset)
			continue
		}
		break
	}

	// convert the entries
	fmt.Print("\nRe-encrypting entries. Please wait; do not force close this process.\n\nGPG may prompt you for a passphrase for decryption.\n\n")
	var outputDir = global.EntryRoot + "-new"
	entries, folders, err := synccommon.WalkEntryDir()
	if err != nil {
		other.PrintError("Failed to walk entry directory: "+err.Error(), back.ErrorRead)
	}
	for _, folder := range folders {
		err := os.MkdirAll(outputDir+strings.ReplaceAll(folder, "/", global.PathSeparator), 0700)
		if err != nil {
			other.PrintError("Failed to create directory: "+err.Error(), back.ErrorWrite)
		}
	}
	var decLines []string
	for _, entry := range entries {
		entry = strings.TrimSuffix(entry, ".gpg")
		decLines = decryptGPG(global.GetRealPath(entry))
		encBytes := wrappers.Encrypt([]byte(strings.Join(decLines, "\n")), rcwPassphrase, true, false)
		err := os.WriteFile(outputDir+strings.ReplaceAll(entry, "/", global.PathSeparator), encBytes, 0600)
		if err != nil {
			other.PrintError("Failed to write to file: "+err.Error(), back.ErrorWrite)
		}
	}

	// swap the new directory with the old one
	err = os.Rename(global.EntryRoot, global.EntryRoot+"-old")
	if err != nil {
		other.PrintError("Failed to rename old directory: "+err.Error(), back.ErrorWrite)
	}
	err = os.Rename(outputDir, global.EntryRoot)
	if err != nil {
		other.PrintError("Failed to rename new directory: "+err.Error(), back.ErrorWrite)
	}
}
