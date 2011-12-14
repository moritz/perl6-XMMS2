use v6;
use NativeCall;
use XMMS2::Result;

# Pointer to an xmms2d connection
class xmmsc_connection_t is OpaquePointer { };

# Native functions
sub xmmsc_playback_stop(OpaquePointer $xmmsc_connection_t)
    returns OpaquePointer #xmmsc_result_t
    is native('libxmmsclient.so') { ... }

sub xmmsc_playback_start(OpaquePointer $xmmsc_connection_t)
    returns OpaquePointer #xmmsc_result_t
    is native('libxmmsclient.so') { ... }

sub xmmsc_playback_pause(OpaquePointer $xmmsc_connection_t)
    #returns xmmsc_result_t
    is native('libxmmsclient.so') { ... }

sub xmmsc_playback_current_id(OpaquePointer $xmmsc_connection_t)
    #returns xmmsc_result_t
    is native('libxmmsclient.so') { ... }

sub xmmsc_init(Str $client-name)
    returns OpaquePointer # xmmsc_connection_t
    is native('libxmmsclient.so') { ... }

sub xmmsc_connect(OpaquePointer $xmmsc_connection_t, Str $path)
    returns Int
    is native('libxmmsclient.so') { ... }

sub xmmsc_unref(OpaquePointer $xmmsc_connection_t)
    is native('libxmmsclient.so') { ... }

sub xmmsc_get_last_error(OpaquePointer $xmmsc_connection_t)
    returns Str
    is native('libxmmsclient.so') { ... }

# Wrapper around a connection pointer
class XMMS2::Connection {
    has OpaquePointer $!xmmsc_connection_t;

    method new(Str $client-name, Str $path?) {
        self.bless(*, :$client-name, :$path);
    }

    submethod BUILD(Str :$client-name, Str :$path?) {
        # FIXME: xmmsc_init can return NULL, on out-of-memory.
        # That might sound stupid but it's still rude to ignore errors.
        $!xmmsc_connection_t = xmmsc_init($client-name);

        # NULL $path instead of a string makes the lib pick a sane default
        xmmsc_connect($!connection, $path // %*ENV<XMMS_PATH> // Str)
            or die "Connecting via '$path' failed with error: {xmmsc_get_last_error($!connection)}";
    }

    method playback_stop returns XMMS2::Result {
        return XMMS2::Result.new: result => xmmsc_playback_stop($!connection);
    }

    method playback_start returns XMMS2::Result {
        return XMMS2::Result.new: result => xmmsc_playback_start($!connection);
    }

    method playback_pause returns XMMS2::Result {
        return XMMS2::Result.new: result => xmmsc_playback_pause($!connection);
    }

    method playback_toggle returns XMMS2::Result {
        return ???
            ?? XMMS2::Result.new: result => self.playback_pause;
            !! XMMS2::Result.new: result => self.playback_start;
    }

    method playback_current_id returns XMMS2::Result {
        return XMMS2::Result.new: result => xmmsc_playback_current_id($!connection);
    }

    submethod DESTROY {
        note 'destroy called on Connection';
        xmmsc_unref($!connection);
    }
}
