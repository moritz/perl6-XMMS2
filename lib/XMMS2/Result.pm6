use v6;
use NativeCall;
use XMMS2::Value;

# TODO: should probably be a lexical class in XMMS2::Connection

# Native functions
sub xmmsc_result_wait(OpaquePointer $xmmsc_result_t)
    is native('libxmmsclient.so') { ... }

sub xmmsc_result_get_value(OpaquePointer $xmmsc_result_t)
    returns OpaquePointer #xmmsv_t
    is native('libxmmsclient.so') { ... }

sub xmmsc_result_unref(OpaquePointer $xmmsc_result_t)
    is native('libxmmsclient.so') { ... }

# Wrapper around a result object, which in turn is just a wrapper around a value...
class XMMS2::Result {
    has OpaquePointer $!xmmsc_result_t;

    method new(OpaquePointer :$result) {
        self.bless(*, xmmsc_result_t => $result);
    }

    # Returns false if this result contains an error status
    method Bool {
        return self.get_value.Bool;
    }

    method Int {
        return self.get_value.Int;
    }

    # Get result value
    method get_value {
        xmmsc_result_wait($!xmmsc_result_t);
        return XMMS2::Value.new: value => xmmsc_result_get_value($!xmmsc_result_t);
    }

    submethod DESTROY {
        xmmsc_result_unref($!xmmsc_result_t);
    }
}
