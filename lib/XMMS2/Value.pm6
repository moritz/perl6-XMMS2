use v6;
use NativeCall;

#= XMMS2 value struct, which is more or less a typeless scalar
class xmmsv_t is repr('CPointer') { }

#= Wrapper around an XMMS2 value
class XMMS2::Value {
    # Native functions for Value
    sub xmmsv_is_error(xmmsv_t)
        returns Int
        is native('libxmmsclient.so') { ... }

    sub xmmsv_get_error(xmmsv_t, Str $error is rw)
        returns Int
        is native('libxmmsclient.so') { ... }

    sub xmmsv_get_int(xmmsv_t, Int $value is rw)
        returns Int
        is native('libxmmsclient.so') { ... }

    has xmmsv_t $!value;

    method new(xmmsv_t $value) {
        self.bless(*, :$value);
    }

    # FIXME: do not want
    submethod BUILD(xmmsv_t :$value) {
        $!value = $value;
    }

    #= Returns false if this is an error value
    method Bool {
        return !xmmsv_is_error($!value);
    }

    method Int {
        if xmmsv_get_int($!value, my Int $i) {
            return $i;
        }

        return Int;
    }

    #= Gets the error string from a value, if defined
    method error_string returns Str {
        if !self and xmmsv_get_error($!value, my Str $error) {
            return $error;
        }

        return Str;
    }
}
