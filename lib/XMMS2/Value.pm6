use v6;
use NativeCall;

#= XMMS2 value struct xmmsv_t, which is more or less a typeless scalar
class XMMS2::Value is repr('CPointer') {
    my sub xmmsv_is_error(XMMS2::Value) returns Int
        is native('libxmmsclient.so') { ... }

    my sub xmmsv_get_error(XMMS2::Value, Str $error is rw) returns Int
        is native('libxmmsclient.so') { ... }

    my sub xmmsv_get_int(XMMS2::Value, Int $value is rw) returns Int
        is native('libxmmsclient.so') { ... }

    #= Returns false if this is an error value
    method Bool {
        return !xmmsv_is_error(self);
    }

    method Int {
        if xmmsv_get_int(self, my Int $i) {
            return $i;
        }

        return Int;
    }

    #= Gets the error string from a value, if defined
    method error_string returns Str {
        if !self and xmmsv_get_error(self, my Str $error) {
            return $error;
        }

        return Str;
    }
}
