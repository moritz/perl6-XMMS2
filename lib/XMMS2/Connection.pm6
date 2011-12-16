use v6;
use NativeCall;
use XMMS2::Value;

#= An xmms2d client connection handle (xmmsc_connection_t)
class XMMS2::Connection is repr('CPointer') {

    #= All commands sent to the server return a result handle (xmmsc_result_t)
    my class Result is repr('CPointer') {
        #= Blocks until a command completes
        sub xmmsc_result_wait(Result)
            is native('libxmmsclient.so') { ... }

        sub xmmsc_result_get_value(Result)
            returns XMMS2::Value
            is native('libxmmsclient.so') { ... }

        sub xmmsc_result_unref(Result)
            is native('libxmmsclient.so') { ... }

        #= Returns false if this result contains an error status
        method Bool {
            return self.get_value.Bool;
        }

        method Int {
            return self.get_value.Int;
        }

        # Get result value
        method get_value {
            xmmsc_result_wait(self);
            return xmmsc_result_get_value(self);
        }

        submethod DESTROY {
            xmmsc_result_unref(self);
        }
    }

    # Native functions for Connection
    sub xmmsc_playback_stop(XMMS2::Connection)
        returns Result
        is native('libxmmsclient.so') { ... }

    sub xmmsc_playback_start(XMMS2::Connection)
        returns Result
        is native('libxmmsclient.so') { ... }

    sub xmmsc_playback_pause(XMMS2::Connection)
        returns Result
        is native('libxmmsclient.so') { ... }

    sub xmmsc_playback_current_id(XMMS2::Connection)
        returns Result
        is native('libxmmsclient.so') { ... }

    sub xmmsc_init(Str $client-name)
        returns XMMS2::Connection
        is native('libxmmsclient.so') { ... }

    sub xmmsc_connect(XMMS2::Connection, Str $path)
        returns Int
        is native('libxmmsclient.so') { ... }

    sub xmmsc_unref(XMMS2::Connection)
        is native('libxmmsclient.so') { ... }

    sub xmmsc_get_last_error(XMMS2::Connection)
        returns Str
        is native('libxmmsclient.so') { ... }

    method open(Str $client-name, Str $path?) returns XMMS2::Connection {
        my XMMS2::Connection $connection = xmmsc_init($client-name)
            or die 'xmmsc_init returned null, out of memory?';

        #= A NULL instead of a string makes the lib pick a sane default
        xmmsc_connect($connection, $path // %*ENV<XMMS_PATH> // Str)
            or die xmmsc_get_last_error($connection)\
                    .fmt(qq{Connecting via "$path" failed with error: %s});

        return $connection;
    }

    method playback_stop returns Result {
        return xmmsc_playback_stop(self);
    }

    method playback_start returns Result {
        return xmmsc_playback_start(self);
    }

    method playback_pause returns Result {
        return xmmsc_playback_pause(self);
    }

    method playback_current_id returns Result {
        return xmmsc_playback_current_id(self);
    }

    method playback_toggle returns Result {
        return ???
            ?? self.playback_pause();
            !! self.playback_start();
    }

    submethod DESTROY {
        xmmsc_unref(self);
    }
}
