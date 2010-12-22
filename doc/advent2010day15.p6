#!/usr/bin/env perl6
use v6;

=begin comment

This is the article I wrote for the Perl 6 2010 Advent Calendar series, as a perl6 script. Running
it with Rakudo should cause your local XMMS2 to start playing, then you'll get a Null PMC error.
Work in progress...

=end comment

=begin pod

=head1 Calling native libraries from Perl 6

If you've used Perl 5 for any length of time, you've probably encountered a package with "::XS" in
the name. Maybe you've even written one, in which case you can skip this paragraph. I<XS> is Perl
5's way of calling into native code (C libraries), and it works great for what it does. Writing such
modules takes effort though; there's C code and compilers involved, and it's not much fun if you
just want to get something working with a minimum of effort.

Perl 6 puts a lot of effort into letting you be lazy. That goes for using foreign code too. Let's
tell it we're going to do that:

=end pod

use NativeCall;

=begin pod

That's it. C<NativeCall> (implemented by L<zavolaj|https://github.com/jnthn/zavolaj>, in Rakudo's
case) does the hard work of talking to C libraries; you don't need to manually compile anything.

Let's have some fun with it. For demonstration, I'll go and port L<part 1 of XMMS2's C client
tutorial|http://git.xmms.se/cgit.cgi/xmms2/xmms2-tutorial/tree/c> to Perl 6.

First off, NativeCall needs to know how to talk to the C library. At present it knows how to
translate to/from strings, numbers, and a thing called C<OpaquePointer>. That last one is for things
like database connection handles that you normally don't want to poke directly.

There's a lot of OpaquePointers in this code, so here's a few subclasses to make it easier to
follow:

=end pod

class xmmsc_connection_t is OpaquePointer;
class xmmsc_result_t is OpaquePointer;
class xmmsv_t is OpaquePointer;

=begin pod

Now the C functions we're using, in alphabetical order:

=end pod

sub xmmsc_connect(xmmsc_connection_t, Str $path)
    returns Int
    is native('libxmmsclient') { ... }

sub xmmsc_get_last_error(xmmsc_connection_t)
    returns Str
    is native('libxmmsclient') { ... }

sub xmmsc_init(Str $clientname)
    returns xmmsc_connection_t
    is native('libxmmsclient') { ... }

sub xmmsc_playback_start(xmmsc_connection_t)
    returns xmmsc_result_t
    is native('libxmmsclient') { ... }

sub xmmsc_result_get_value(xmmsc_result_t)
    returns xmmsv_t
    is native('libxmmsclient') { ... }

sub xmmsc_result_unref(xmmsc_result_t)
    is native('libxmmsclient') { ... }

sub xmmsc_result_wait(xmmsc_result_t)
    is native('libxmmsclient') { ... }

sub xmmsc_unref(xmmsc_connection_t)
    is native('libxmmsclient') { ... }

sub xmmsv_get_error(xmmsv_t, Str $error is rw)
    returns Int
    is native('libxmmsclient') { ... }

sub xmmsv_is_error(xmmsv_t)
    returns Int
    is native('libxmmsclient') { ... }

=begin pod

And because the point of this is to *avoid* writing C code, let's make a nice wrapper object:

=end pod

class XMMS2::Client {
    has xmmsc_connection_t $!connection;

    method new($client_name = 'p6xmms2', $path = %*ENV<XMMS_PATH>) {
        self.bless(*, :$client_name, :$path);
    }

    method play returns Bool {
        my $result = xmmsc_playback_start($!connection);
        xmmsc_result_wait($result);
        return True if self.check-result($result);

        warn "Playback start failed!";
        return False;
    }

    method check-result($result) returns Bool {
        my $return_value = xmmsc_result_get_value($result);
        my $failed = xmmsv_is_error($return_value);

        if $failed {
            my $error-str;
            xmmsv_get_error($return_value, $error-str)
                and warn $error-str;
        }

        xmmsc_result_unref($result);

        return not $failed;
    }

    submethod BUILD($client_name, $path) {
        $!connection = xmmsc_init($client_name);
        xmmsc_connect($!connection, $path || pir::null__P())
            or die "Connection failed with error: {xmmsc_get_last_error($!connection)}";
    }

    submethod DESTROY {
        xmmsc_unref($!connection);
    }
};

=begin pod

And now that I've written all that, here's where the magic happens:

=end pod

XMMS2::Client.new.play;
