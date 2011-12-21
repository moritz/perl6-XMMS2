use v6;
use XMMS2::Connection;

#####
# A bit of syntactic sugar over the raw API
class XMMS2::Client {
    has XMMS2::Connection $!connection;

    method new(Str $client-name = 'perl6-XMMS2', Str $path?) {
        self.bless(*, :$client-name, :$path);
    }

    submethod BUILD(Str :$client-name, Str :$path?) {
        $!connection .= open($client-name, $path);
    }

    method play returns Bool {
        return ?$!connection.playback_start;
    }

    method pause returns Bool {
        return ?$!connection.playback_pause;
    }

    method stop returns Bool {
        return ?$!connection.playback_stop;
    }

    method toggle returns Bool {
        ???
    }

    method prev returns Bool {
        ???
    }

    method next returns Bool {
        ???
    }

    method current returns Int {
        return $!connection.playback_current_id;
    }
}
