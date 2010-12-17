use v6;
use NativeCall;
use XMMS2::Value;

# Result struct from a command
class xmmsc_result_t is OpaquePointer { };

# Native functions
sub xmmsc_result_wait(xmmsc_result_t)
    is native('libxmmsclient') { ... }

sub xmmsc_result_get_value(xmmsc_result_t --> xmmsv_t)
    is native('libxmmsclient') { ... }

sub xmmsc_result_unref(xmmsc_result_t)
    is native('libxmmsclient') { ... }

# Wrapper around a result object
class XMMS2::Result;
has xmmsc_result_t $.result;

# Check whether this result is an error status
method ok(:$verbose!) returns Bool {
    xmmsc_result_wait($!result);
    my $status = XMMS2::Value.new: xmmsc_result_get_value($!result);
    my $failed = ?$status.error;

    if $verbose and $failed {
        warn $status.error;
    }

    return not $failed;
}

submethod DESTROY {
    xmmsc_result_unref($!result);
}
