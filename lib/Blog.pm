package Blog;
use strict;
use warnings;
use parent qw/Amon2/;
our $VERSION='0.01';

use Amon2::Config::Simple;
sub load_config { Amon2::Config::Simple->load(shift) }

use Amon2x::DBI;
sub dbh {
    my $c = shift;
    $c->{dbh} //= do {
        my $conf = $c->config->{DB} // die "missing configuration for database";
        return Amon2x::DBI->connect(@$conf);
    };
}

1;
