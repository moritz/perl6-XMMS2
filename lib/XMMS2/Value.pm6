use v6;
use NativeCall;

# XMMS2 variant value
class xmmsv_t is OpaquePointer { };

# Native functions
sub xmmsv_is_error(xmmsv_t)
    returns Int
    is native('libxmmsclient') { ... }

sub xmmsv_get_error(xmmsv_t, Str $error is rw)
    returns Int
    is native('libxmmsclient') { ... }

# Wrapper around an XMMS2 value struct
class XMMS2::Value;
has $!value;

method error returns Str {
    return Str unless xmmsv_is_error($!value);

    xmmsv_get_error($!value, my $error-str);
    return $error-str;
}
