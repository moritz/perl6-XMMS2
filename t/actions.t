#!/usr/bin/env perl6
use v6;
use Test;
use XMMS2::Client;

plan 6;

unless %*ENV<XMMS_PATH> {
    warn 'Set XMMS_PATH if you really want to run this, it\'ll mess with your playback';
    skip_rest("\%*ENV<XMMS_PATH> required for this test");
    exit;
}

my XMMS2::Client $xmms2;

unless lives_ok { $xmms2 .= new(:client-name<perl6xmms2test>) }, 'Connect' {
    skip_rest("Couldn't connect");
    exit 1;
}

ok $xmms2.stop, 'Stopping playback';
diag 'XMMS2 should now be stopped. Will now play for 2s, pause 2s, play 2s then stop';

ok $xmms2.play, 'Play';
diag 'XMMS2 should now be playing';
sleep 2;

ok $xmms2.pause, 'Pause';
diag 'XMMS2 should now be paused';
sleep 2;

ok $xmms2.play, 'Resuming playback';
diag 'XMMS2 should now be playing again';
sleep 2;

ok $xmms2.stop, 'Stop';
diag 'XMMS2 should now be stopped; end of test';

# vim: set ft=perl6 :
