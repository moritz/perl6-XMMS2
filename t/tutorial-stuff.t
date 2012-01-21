#!/usr/bin/env perl6
use Test;
use XMMS2::Connection;

# Perform all the actions in xmms2-tutorial/c/. We use the raw XMMS2::Connection
# here, XMMS2::Client is tested in actions.t.

unless %*ENV<RUN_TEST> {
    warn 'This test will interfere with your audio; set RUN_TEST to run it';
    skip_rest("\%*ENV<RUN_TEST> required for this test");
    exit 1;
}

my XMMS2::Connection $xmms2;

unless lives_ok { $xmms2 .= open(:client-name<perl6xmms2test>) }, 'Connect to xmms2' {
    skip_rest("Couldn't connect");
    exit 1;
}

# tut1.c
ok(?$xmms2.playback_start, 'Start playback');
