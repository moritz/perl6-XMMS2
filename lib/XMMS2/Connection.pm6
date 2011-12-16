use v6;
use NativeCall;
use XMMS2::Value;

#= An xmms2d connection handle
class xmmsc_connection_t is repr('CPointer') { }

#= All commands sent to the server return a result handle
class xmmsc_result_t is repr('CPointer') { }

#= Wrapper around a connection pointer
class XMMS2::Connection {
    #= Wrapper around a result handle
    my class Result {
        # Native functions for Result
        #= Blocks until a command completes
        sub xmmsc_result_wait(xmmsc_result_t)
            is native('libxmmsclient.so') { ... }

        sub xmmsc_result_get_value(xmmsc_result_t)
            returns xmmsv_t
            is native('libxmmsclient.so') { ... }

        sub xmmsc_result_unref(xmmsc_result_t)
            is native('libxmmsclient.so') { ... }

        has xmmsc_result_t $!result;
        has Bool $!received = False;

        method new(xmmsc_result_t $result) {
            self.bless(*, :$result);
        }

        # FIXME: new() breaks without this, but I don't see why I have to be this verbose.
        submethod BUILD(xmmsc_result_t :$result) {
            $!result = $result;
        }

        #= Returns false if this result contains an error status
        method Bool {
            return self.get_value.Bool;
        }

        method Int {
            return self.get_value.Int;
        }

        # Get result value
        method get_value {
            unless $!received {
                xmmsc_result_wait($!result);
                $!received = True;
            }
            return XMMS2::Value.new: xmmsc_result_get_value($!result);
        }

        submethod DESTROY {
            xmmsc_result_unref($!result);
        }
    }

    # Native functions for Connection
    sub xmmsc_playback_stop(xmmsc_connection_t)
        returns xmmsc_result_t
        is native('libxmmsclient.so') { ... }

    sub xmmsc_playback_start(xmmsc_connection_t)
        returns xmmsc_result_t
        is native('libxmmsclient.so') { ... }

    sub xmmsc_playback_pause(xmmsc_connection_t)
        returns xmmsc_result_t
        is native('libxmmsclient.so') { ... }

    sub xmmsc_playback_current_id(xmmsc_connection_t)
        returns xmmsc_result_t
        is native('libxmmsclient.so') { ... }

    sub xmmsc_init(Str $client-name)
        returns xmmsc_connection_t
        is native('libxmmsclient.so') { ... }

    sub xmmsc_connect(xmmsc_connection_t, Str $path)
        returns Int
        is native('libxmmsclient.so') { ... }

    sub xmmsc_unref(xmmsc_connection_t)
        is native('libxmmsclient.so') { ... }

    sub xmmsc_get_last_error(xmmsc_connection_t)
        returns Str
        is native('libxmmsclient.so') { ... }

    has xmmsc_connection_t $!connection;

    method new(Str $client-name, Str $path?) {
        self.bless(*, :$client-name, :$path);
    }

    submethod BUILD(Str :$client-name, Str :$path?) {
        $!connection = xmmsc_init($client-name)
            or die 'xmmsc_init returned null, out of memory?';

        #= A NULL instead of a string makes the lib pick a sane default
        xmmsc_connect($!connection, $path // %*ENV<XMMS_PATH> // Str)
            or die xmmsc_get_last_error($!connection)\
                    .fmt(qq{Connecting via "$path" failed with error: %s});
    }

    method playback_stop returns Result {
        return Result.new: xmmsc_playback_stop($!connection);
    }

    method playback_start returns Result {
        return Result.new: xmmsc_playback_start($!connection);
    }

    method playback_pause returns Result {
        return Result.new: xmmsc_playback_pause($!connection);
    }

    method playback_current_id returns Result {
        return Result.new: xmmsc_playback_current_id($!connection);
    }

    method playback_toggle returns Result {
        return ???
            ?? self.playback_pause;
            !! self.playback_start;
    }

    submethod DESTROY {
        note 'object destructors work now!';
        xmmsc_unref($!connection);
    }
}
