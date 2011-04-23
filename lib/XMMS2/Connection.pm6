use v6;
use NativeCall;
use XMMS2::Result;

# Pointer to an xmms2d connection
class xmmsc_connection_t is OpaquePointer { };

# Native functions
sub xmmsc_playback_stop(xmmsc_connection_t)
    returns xmmsc_result_t
    is native('libxmmsclient') { ... }

sub xmmsc_playback_start(xmmsc_connection_t)
    returns xmmsc_result_t
    is native('libxmmsclient') { ... }

sub xmmsc_playback_pause(xmmsc_connection_t)
    returns xmmsc_result_t
    is native('libxmmsclient') { ... }

sub xmmsc_playback_current_id(xmmsc_connection_t)
    returns xmmsc_result_t
    is native('libxmmsclient') { ... }

sub xmmsc_init(Str $client-name)
    returns xmmsc_connection_t
    is native('libxmmsclient') { ... }

sub xmmsc_connect(xmmsc_connection_t, Str $path)
    returns Int
    is native('libxmmsclient') { ... }

sub xmmsc_unref(xmmsc_connection_t)
    is native('libxmmsclient') { ... }

sub xmmsc_get_last_error(xmmsc_connection_t)
    returns Str
    is native('libxmmsclient') { ... }

# Wrapper around a connection pointer
class XMMS2::Connection;
has xmmsc_connection_t $.connection;

method new(Str $client-name, Str $path = %*ENV<XMMS_PATH>) {
    self.bless(*, :$client-name, :$path);
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

submethod BUILD(Str $client-name, Str $path) {
    # FIXME: xmmsc_init can return NULL, on out-of-memory.
    # That might sound stupid but it's still rude to ignore errors.
    $!connection = xmmsc_init($client-name);

    # NULL instead of a path string makes the lib pick a sane default
    # FIXME: null__P doesn't work in current versions of zavolaj
    xmmsc_connect($!connection, $path || pir::null__P())
        or die "Connecting via '$path' failed with error: {xmmsc_get_last_error($!connection)}";
}

submethod DESTROY {
    xmmsc_unref($!connection);
}
