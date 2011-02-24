package Blog::Web;
use strict;
use warnings;
use parent qw/Blog Amon2::Web/;
use Log::Minimal;

# load all controller classes
use Module::Find ();
Module::Find::useall("Blog::Web::C");

# custom classes
use Blog::Web::Request;
use Blog::Web::Response;
sub create_request  { Blog::Web::Request->new($_[1]) }
sub create_response { shift; Blog::Web::Response->new(@_) }

# dispatcher
use Blog::Web::Dispatcher;
sub dispatch {
    return Blog::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

# setup view class
use Tiffany::Text::Xslate;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || die "missing configuration for Text::Xslate";
    my $view = Tiffany::Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [
            'Text::Xslate::Bridge::TT2Like',
            'HTTP::Date' => [qw/time2str/],
        ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
        },
        warn_handler => sub { warnf('%s', @_) },
        die_handler => sub { critf('%s', @_) },
        %$view_conf
    });
    sub create_view { $view }
}

# load plugins
__PACKAGE__->load_plugins('Web::FillInFormLite');
__PACKAGE__->load_plugins('Web::CSRFDefender');

use HTTP::Session::Store::File;
use File::Path qw/mkpath/;
my $session_path = "/tmp/blog.session.$<";
mkpath $session_path, 1;
my $store = HTTP::Session::Store::File->new( dir => $session_path );
__PACKAGE__->load_plugins('Web::HTTPSession' => {
    state => 'Cookie',
    store => $store,
});

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
    },
);

1;
