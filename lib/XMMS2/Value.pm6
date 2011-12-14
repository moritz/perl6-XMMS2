use v6;
use NativeCall;

# Native functions
sub xmmsv_is_error(OpaquePointer $xmmsv_t)
    returns Int
    is native('libxmmsclient.so') { ... }

sub xmmsv_get_error(OpaquePointer $xmmsv_t, Str $error is rw)
    returns Int
    is native('libxmmsclient.so') { ... }

sub xmmsv_get_int(OpaquePointer $xmmsv_t, Int $value is rw)
    returns Int
    is native('libxmmsclient.so') { ... }

# Wrapper around an XMMS2 value struct
class XMMS2::Value {
    has OpaquePointer $!xmmsv_t;

    # Returns false if this is an error value
    method Bool {
        return !xmmsv_is_error($!xmmsv_t);
    }

    method Int {
        if xmmsv_get_int($!xmmsv_t, my Int $i) {
            return $i;
        }

        return Int;
    }

    # Get the error string from a value
    method error_string returns Str {
        if !self and xmmsv_get_error($!xmmsv_t, my Str $error) {
            return $error;
        }

        return Str;
    }
}
