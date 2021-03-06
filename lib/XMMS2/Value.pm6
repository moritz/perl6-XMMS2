#= XMMS2 value struct xmmsv_t, which is more or less a typeless scalar
class XMMS2::Value:auth<github:flussence>:ver<0.1.0> is repr<CPointer>;

use NativeCall;

my sub xmmsv_is_error(XMMS2::Value) returns Int
    is native<libxmmsclient> { ... }

my sub xmmsv_get_error(XMMS2::Value, Str $error is rw) returns Int
    is native<libxmmsclient> { ... }

my sub xmmsv_get_int(XMMS2::Value, Int $value is rw) returns Int
    is native<libxmmsclient> { ... }

method Bool { !xmmsv_is_error(self) } #= false if error
method Int { xmmsv_get_int(self, my Int $i) ?? $i !! Int }

# no need for us to call is_error manually, get_error does it for us
method error { xmmsv_get_error(self, my Str $error) and $error }
