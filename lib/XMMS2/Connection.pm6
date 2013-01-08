use v6;
use NativeCall;
use XMMS2::Value;

#= An xmms2d client connection handle (xmmsc_connection_t)
class XMMS2::Connection is repr<CPointer> {

    #= All commands sent to the server return a result handle (xmmsc_result_t)
    my class Result is repr<CPointer> {
        #= Blocks until a command completes
        my sub xmmsc_result_wait(Result)
            is native<libxmmsclient> { ... }

        my sub xmmsc_result_get_value(Result) returns XMMS2::Value
            is native<libxmmsclient> { ... }

        my sub xmmsc_result_unref(Result)
            is native<libxmmsclient> { ... }

        method Bool { self.get_value.Bool } #= false if error
        method Int { self.get_value.Int }

        # Get result value
        method get_value returns XMMS2::Value {
            xmmsc_result_wait(self);
            return xmmsc_result_get_value(self);
        }

        submethod DESTROY { xmmsc_result_unref(self) }
    }

    # Native functions for Connection
    my sub xmmsc_init(Str $client-name) returns XMMS2::Connection
        is native<libxmmsclient> { ... }

    my sub xmmsc_connect(XMMS2::Connection, Str $path) returns Int
        is native<libxmmsclient> { ... }

    my sub xmmsc_get_last_error(XMMS2::Connection) returns Str
        is native<libxmmsclient> { ... }

    my sub xmmsc_playback_stop(XMMS2::Connection) returns Result
        is native<libxmmsclient> { ... }

    my sub xmmsc_playback_start(XMMS2::Connection) returns Result
        is native<libxmmsclient> { ... }

    my sub xmmsc_playback_pause(XMMS2::Connection) returns Result
        is native<libxmmsclient> { ... }

    my sub xmmsc_playback_current_id(XMMS2::Connection) returns Result
        is native<libxmmsclient> { ... }

    my sub xmmsc_unref(XMMS2::Connection)
        is native<libxmmsclient> { ... }

    method open(Str $client-name, Str $path?) {
        my XMMS2::Connection $connection = xmmsc_init($client-name)
            or die 'xmmsc_init returned null, out of memory?';

        #= A NULL instead of a string makes the lib pick a sane default
        xmmsc_connect($connection, $path // %*ENV<XMMS_PATH> // Str)
            or die xmmsc_get_last_error($connection);

        return $connection;
    }

    method playback_stop returns Result { xmmsc_playback_stop(self) }
    method playback_start returns Result { xmmsc_playback_start(self) }
    method playback_pause returns Result { xmmsc_playback_pause(self) }
    method playback_current_id returns Result { xmmsc_playback_current_id(self) }

    submethod DESTROY { xmmsc_unref(self) }
}
