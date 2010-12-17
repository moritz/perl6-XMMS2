use v6;
use NativeCall;
use XMMS2::Client::Connection;

#####
# The user-interfaceable part
class XMMS2::Client {
    has $!connection;

    method new(Str $client_name = 'perl6-XMMS2', Str $path = %*ENV<XMMS_PATH>) {
        self.bless(*, :$client_name, :$path);
    }

    method play returns Bool {
        $!connection.play;
    }

    submethod BUILD(Str $client_name, Str $path) {
        $!connection = XMMS2::Client::Connection.new($client_name, $path);
    }
};
