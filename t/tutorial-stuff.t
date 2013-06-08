#!/usr/bin/env perl6
use Test;
use XMMS2::Connection;

plan 1;

# Perform all the actions in xmms2-tutorial/c/. We use the raw XMMS2::Connection
# here, XMMS2::Client is tested in actions.t.

unless %*ENV<XMMS_PATH> {
    warn 'Set XMMS_PATH if you really want to run this, it\'ll mess with your playback';
    skip_rest("\%*ENV<XMMS_PATH> required for this test");
    exit;
}

my XMMS2::Connection $xmms2;

unless lives_ok { $xmms2 .= open('perl6xmms2test') }, 'Connect to xmms2' {
    skip_rest("Connection failed: {$!}");
    exit 1;
}

# tut1.c
ok(?$xmms2.playback_start, 'Start playback');
