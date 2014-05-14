# perl6-XMMS2

An XMMS2 client module for Perl 6 and a command line tool to use it with, inspired by tadzik++'s
[perl6-MPD](//github.com/tadzik/perl6-MPD).

I'm implementing bits of the xmms2-tutorial C code. This is being done mostly for my own amusement,
but if you find it useful then even better.

Currently supports connecting, play/pause/stop, and can tell you the current track number.

## Known Bugs

* Resource freeing is done using perl6's standard destructors. Rakudo doesn't implement those yet,
  so you'll eventually run out of memory. I can't find a sane way to work around this.
