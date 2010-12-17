use v6;
use NativeCall;
use XMMS2::Result;

# Pointer to an xmms2d connection
class xmmsc_connection_t is OpaquePointer { };

# Native functions
sub xmmsc_playback_start(xmmsc_connection_t --> xmmsc_result_t)
    is native('libxmmsclient') { ... }

sub xmmsc_init(Str $clientname --> xmmsc_connection_t)
    is native('libxmmsclient') { ... }

sub xmmsc_connect(xmmsc_connection_t, Str $path --> Int)
    is native('libxmmsclient') { ... }

sub xmmsc_unref(xmmsc_connection_t)
    is native('libxmmsclient') { ... }

sub xmmsc_get_last_error(xmmsc_connection_t --> Str)
    is native('libxmmsclient') { ... }

# Wrapper around a connection pointer
class XMMS2::Connection;
has xmmsc_connection_t $.connection;

method new(Str $client_name, Str $path = %*ENV<XMMS_PATH>) {
    self.bless(*, :$client_name, :$path);
}

# TODO: there's async API, but this doesn't do that yet.
method play(:$synchronous!) returns Bool {
    my $result = 
    my Bool $success = XMMS2::Result.new(:result => xmmsc_playback_start($!connection)).ok;

    warn 'Playback start failed!' if not $success;

    return $success;
}

submethod BUILD(Str $client_name, Str $path) {
    # FIXME: this can return NULL in an out-of-memory condition. No matter how implausible that
    # might sound, it should still be checked...
    $!connection = xmmsc_init($client_name);

    xmmsc_connect($!connection, $path || pir::null__P())
        or die "Connecting via '$path' failed with error: {xmmsc_get_last_error($!connection)}";
}

submethod DESTROY {
    xmmsc_unref($!connection);
}
