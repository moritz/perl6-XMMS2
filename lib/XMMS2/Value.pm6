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
has xmmsv_t $!value;

# Returns false if this is an error value
method Bool {
    return !xmmsv_is_error($!value);
}

# Get the error string from a value
method error_string returns Str {
    my Str $error;
    xmmsv_get_error($!value, $error) if !self;

    return $error;
}
