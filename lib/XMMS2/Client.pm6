use v6;
use NativeCall;

#####
# Pointer to an xmms2d connection
class xmmsc_connection_t is OpaquePointer {
    # This doesn't seem to work. It'd be nice if it did though.
    #submethod DESTROY { xmmsc_unref(self) }
}

# Result struct from a command
class xmmsc_result_t is OpaquePointer {
    #submethod DESTROY { xmmsc_result_unref(self) }
}

# XMMS2 variant value
class xmmsv_t is OpaquePointer;

#####
# The nice part that does stuff
class XMMS2::Client {
    has xmmsc_connection_t $!connection;

    method new(Str $client_name = 'p6xmms2', Str $path = %*ENV<XMMS_PATH>) {
        self.bless(*, :$client_name, :$path);
    }

    method play returns Bool {
        my Bool $success = self!ok: xmmsc_playback_start($!connection);

        warn 'Playback start failed!' if not $success;

        return $success;
    }

    # Check for error status from anything that returns an xmmsc_result_t.
    # Also frees the result value.
    method !ok(xmmsc_result_t $result) returns Bool {
        my $command_status = xmmsc_result_get_value($result);

        my $failed = xmmsv_is_error($command_status);

        if $failed {
            xmmsv_get_error($command_status, my $error-str) and warn $error-str;
        }

        xmmsc_result_unref($result);

        return not $failed;
    }

    # FIXME: libxmmsclient has this default $path, but you have to pass a C NULL value as the path
    # to make it use it, which I don't know how to do using zavolaj yet.
    submethod BUILD(Str $client_name, Str $path = "unix:///tmp/xmms2-ipc-{qx[whoami].trim}") {
        $!connection = xmmsc_init($client_name);

        xmmsc_connect($!connection, $path)
            or die "Connecting via '$path' failed with error: {xmmsc_get_last_error($!connection)}";
    }

    submethod DESTROY {
        xmmsc_unref($!connection);
    }
}

#####
# C functions in alphaspaghetti order
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
