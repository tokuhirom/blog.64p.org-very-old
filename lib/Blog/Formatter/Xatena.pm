use strict;
use warnings;
use utf8;

package Blog::Formatter::Xatena;
use Text::Xatena;

my $xatena = Text::Xatena->new(
    inline => 'Blog::Formatter::Xatena::Inline',
);
sub format {
    my ($class, $src) = @_;
    $src =~ s/\r\n/\n/g; # Xatena does not support \r\n@0.08 -- tokuhirom@20110219
    $xatena->format($src);
}

package Blog::Formatter::Xatena::Inline;
use Text::Xatena::Inline::Base -Base;
use URI::Escape qw/uri_escape/;

match qr{L<([a-zA-Z0-9:]+)>}i => sub {
    my ($self, $pkg) = @_;
    sprintf('<a href="http://frepan.org/perldoc?%s">%s</a>', uri_escape($pkg), $pkg);
};

match qr{([A-Z][a-zA-Z0-9_]+::[a-zA-Z0-9:_]+)}i => sub {
    my ($self, $pkg) = @_;
    sprintf('<a href="http://frepan.org/perldoc?%s">%s</a>', uri_escape($pkg), $pkg);
};

match qr{\@([a-z0-9]+)} => sub {
    my ( $self, $twitter_id ) = @_;
    sprintf( '<a href="http://twitter.com/%s">@%s</a>',
        $twitter_id, $twitter_id, );
};

1;

