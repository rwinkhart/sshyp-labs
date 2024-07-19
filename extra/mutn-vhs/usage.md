# MUTN VHS Tape Creation
1. Ensure `mutn` is in your path
2. If `zsh` is not installed, either install it or change the shell in `cassette.tape` (for some reason the "Up" function only works in `zsh` for me)
3. Import example.asc (if not done already) with password `example`
4. Set up a client-server pair using the `libmutton` entries folder provided in this repo
5. Run the following "reset" command from within this folder (it's okay if it throws errors; this is expected if running before using `vhs`):
    - `rm -rf ~/.local/share/libmutton && cp -r ./libmutton ~/.local/share/libmutton && mutn sync && mutn /notes/school/world\ history/the\ best\ day\ ever shear; rm ~/.local/share/libmutton/notes/school/ccnp\ networking/{chapter\ 4,chapter\ 5} && gpgconf --kill gpg-agent`
6. Run `vhs ./cassette.tape`
7. View mutn-demo.gif! Use the above "reset" command between each recording.

# Read for Production
Before posting for production, I convert the GIF to an animated WEBP (to save space) using libwebp's `gif2webp`:

`gif2webp -min_size -q 100 -m 6 ./mutn-demo.gif -o ./mutn-demo.webp`
