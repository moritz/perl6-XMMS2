use v6;
use NativeCall;
use XMMS2::Connection;

#####
# The user-interfaceable part
class XMMS2::Client;
has $!connection;

method new(Str $client-name = 'perl6-XMMS2', Str $path = %*ENV<XMMS_PATH>) {
    self.bless(*, :$client-name, :$path);
}

method play returns Bool {
    $!connection.play;
}

method pause returns Bool {
    ???
}

method toggle returns Bool {
    ???
}

method stop returns Bool {
    ???
}

method prev returns Bool {
    ???
}

method next returns Bool {
    ???
}

submethod BUILD(Str $client-name, Str $path) {
    $!connection = XMMS2::Connection.new($client-name, $path);
}
