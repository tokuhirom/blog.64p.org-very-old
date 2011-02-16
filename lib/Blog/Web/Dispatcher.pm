package Blog::Web::Dispatcher;
use strict;
use warnings;
use 5.12.2;

use Blog::M::Entry;
use Amon2::Web::Dispatcher::Lite;

any '/' => sub {
    my ($c) = @_;

    my $current_page = $c->req->param('page') // 1;
    my ($entries, $has_next) = Blog::M::Entry->search(
        entries_per_page => 20,
        current_page     => $current_page,
    );

    $c->render('index.tt', {
        entries => $entries,
        has_next => $has_next,
        page     => $current_page,
    });
};

any '/index.rss' => sub {
    my ($c) = @_;

    my ($entries, $has_next) = Blog::M::Entry->search(
        entries_per_page => 20,
        current_page     => 1,
    );

    my $res = $c->render('index.rss.tt', {
        entries => $entries,
    });
    $res->content_type('application/xml; charset=UTF-8');
    return $res;
};

get '/entry/{entry_id}' => sub {
    my ($c, $args) = @_;
    my $entry_id = $args->{entry_id};
    my $entry = Blog::M::Entry->retrieve(entry_id => $entry_id) // $c->res_404();
    $c->render('entry.tt', {
        entry => $entry,
        title => "$entry->{title} - blog.64p.org",
    });
};

any '/admin/add' => sub {
    my ($c) = @_;

    $c->render('admin/add.tt', { });
};

post '/admin/do_add' => sub {
    my ($c) = @_;

    if (my $body = $c->req->param('body')) {
        Blog::M::Entry->insert(
            title => $c->req->param('title') // 'no title',
            body => $body,
            format => $c->req->param('format') || 'hatena',
        );
    }

    return $c->redirect('/');
};

any '/admin/edit' => sub {
    my ($c) = @_;

    my $entry_id = $c->req->param('entry_id') // die "missing mandatory parameter: entry_id";
    my $entry = Blog::M::Entry->retrieve(entry_id => $entry_id) // $c->res_404();
    $c->fillin_form($entry);
    $c->render('admin/edit.tt', { entry_id => $entry_id });
};

post '/admin/do_edit' => sub {
    my ($c) = @_;

    my $entry_id = $c->req->param('entry_id') // die "Missing mandatory parameter: entry_id";
    if (my $body = $c->req->param('body')) {
        Blog::M::Entry->update(
            entry_id => $entry_id,
            title    => $c->req->param('title') // 'no title',
            body     => $body,
            format   => $c->req->param('format') || 'hatena',
        );
    }

    return $c->redirect("/entry/$entry_id");
};

1;
