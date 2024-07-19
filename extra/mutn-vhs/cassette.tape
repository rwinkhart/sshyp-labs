Require mutn
Require gpg

Set Theme { "name": "GruvboxDarkMUTNCustom", "black": "#282828", "red": "#cc241d", "green": "#98971a", "yellow": "#d79921", "blue": "#458588", "magenta": "#b16286", "cyan": "#689d6a", "white": "#d5c4a1", "brightBlack": "#928374", "brightRed": "#fb4934", "brightGreen": "#b8bb26", "brightYellow": "#fabd2f", "brightBlue": "#83a598", "brightMagenta": "#d3869b", "brightCyan": "#8ec07c", "brightWhite": "#ebdbb2", "background": "#272727", "foreground": "#d5c4a1", "selection": "#665c54", "cursor": "#ebdbb2" }

Set Padding 5
Set Framerate 30
Set Height 675
Set Width 1290
Set Shell zsh

Output mutn-demo.gif

Sleep 1s
Type "# start of loop | viewing my entry list :)"
Sleep 800ms
Backspace@25ms 42
Type "mutn"
Sleep 250ms
Enter
Sleep 2.25s
Type "# syncing entries with the server :o"
Sleep 500ms
Backspace@25ms 36
Type "mutn sync"
Enter
Sleep 1.25s
Type "clear"
Sleep 1.5s
Enter
Type "# reading my todo list :^)"
Sleep 500ms
Backspace@25ms 26
Type "mutn /notes/personal/todo"
Enter
Sleep 1s
Type "example"
Enter
Sleep 2s
Type "clear"
Sleep 2.5s
Enter
Type "# changing my github password :p"
Sleep 500ms
Backspace@25ms 32
Type "mutn /development/github gen -u"
Enter
Sleep 500ms
Type "69"
Sleep 500ms
Enter
Sleep 500ms
Type "y"
Sleep 500ms
Enter
Sleep 2s
Enter
Type "# copying the new password :]"
Sleep 500ms
Backspace@25ms 29
Up
Sleep 500ms
Backspace 6
Sleep 500ms
Type "copy"
Enter
Sleep 1s
Enter
Type "# darn, I need my totp token :/"
Sleep 800ms
Backspace@25ms 31
Up
Sleep 500ms
Type " -t"
Enter
Sleep 1s
Enter
Type "as long as the process runs, the token will be refreshed | let's paste it: "
Sleep 250ms
Paste
Sleep 1s
Backspace@25ms 81
Ctrl+c
Sleep 1s
Type "clear"
Sleep 1.5s
Enter
Type "# editing my todo list :|"
Sleep 500ms
Backspace@25ms 25
Type "mutn /notes/personal/todo edit -n"
Sleep 500ms
Enter
Escape
Sleep 1s
Type "jj"
Sleep 500ms
Type "2dd"
Sleep 1s
Type ":wq"
Sleep 500ms
Enter
Sleep 2s
Type "clear"
Sleep 2.5s
Enter
Type "# checking up on my homework :'("
Sleep 500ms
Backspace@25ms 32
Type "mutn /notes/school/homework"
Enter
Sleep 2s
Type "clear"
Sleep 2.5s
Enter
Type "# giving my school notes a better name ;3"
Sleep 500ms
Backspace@25ms 41
Type "mutn /notes/school/world\ history/MUTN\ public\ debut edit -r"
Enter
Sleep 1s
Type "/notes/school/world history/the best day ever"
Enter
Sleep 1.5s
Type "mutn"
Sleep 250ms
Enter
Sleep 1s
Type "# end of loop! (:"
Sleep 3s
