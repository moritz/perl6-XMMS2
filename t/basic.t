#!/usr/bin/env perl6
use v6;
use Test;
use XMMS2::Client;

plan 1;
ok my $xmms2 = XMMS2::Client.new(:client-name<test>), 'Can connect to xmms2d';

# vim: set ft=perl6 :
