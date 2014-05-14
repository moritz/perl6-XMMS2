# perl6-XMMS2

This is a command line tool for XMMS2 (and serves as a neat demo of
[`NativeCall`](//github.com/jnthn/zavolaj) code), inspired by tadzik++'s
[`perl6-MPD`](//github.com/tadzik/perl6-MPD).

Currently does play, pause, stop, and current track number. May do more
practical things in the future.

## Known Bugs

This tries to use the not-fully-specced and not-at-all-implemented `DESTROY()`
method to call the native resource-freeing functions. In theory using this code
in long-running programs will eat all your memory, though you'd have to work
pretty hard to make that happen in the first place.

<!-- vim: tw=80 -->
