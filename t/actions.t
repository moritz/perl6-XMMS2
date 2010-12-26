#!/usr/bin/env perl6
use v6;
use Test;
use XMMS2::Client;

plan 6;

unless %*ENV<XMMS_PATH> {
    warn 'Set XMMS_PATH if you really want to run this, it\'ll mess with your playback';
    skip_rest("\%*ENV<XMMS_PATH> required for this test");
    exit 1;
}

my $xmms2;

unless lives_ok { $xmms2 = XMMS2::Client.new(:client-name<test>) }, 'Connect' {
    skip_rest("Couldn't connect");
    exit 1;
}

ok $xmms2.stop, 'Stopping playback';
say 'Will now play for 2s, pause 2s, play 2s then stop';

ok $xmms2.play, 'Play';
sleep 2;

ok $xmms2.pause, 'Pause';
sleep 2;

ok $xmms2.play, 'Resuming playback';
sleep 2;

ok $xmms2.stop, 'Stop';

# vim: set ft=perl6 :
