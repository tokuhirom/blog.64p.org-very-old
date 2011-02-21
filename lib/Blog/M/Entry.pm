use strict;
use warnings;
use utf8;
use 5.12.2;

package Blog::M::Entry;
use Amon2::Declare;
use Smart::Args;
use Blog::Formatter::Xatena;
use Time::Piece;

sub search {
    args my $class,
         my $entries_per_page,
         my $current_page,
         my $c => {default => c()},
         ;

    my $entries = $c->dbh->selectall_arrayref(
        q{SELECT entry_id, title, body, html, ctime FROM entry ORDER BY entry_id DESC LIMIT ? OFFSET ?},
        {Slice => {}},
        $entries_per_page + 1,
        $entries_per_page * ($current_page-1),
    );
    my $has_next = ( $entries_per_page + 1 == @$entries );
    if ($has_next) { pop @$entries }

    for (@$entries) {
        $_->{ctime} = Time::Piece->new($_->{ctime})->strftime('%Y-%m-%d(%a) %H:%M');
    }

    return ($entries, $has_next);
}

sub retrieve {
    args my $class,
         my $entry_id,
         my $c      => {default => c()},
         ;

    my ($entry) = @{$c->dbh->selectall_arrayref(
        q{SELECT entry_id, title, body, html, ctime FROM entry WHERE entry_id=? ORDER BY entry_id DESC LIMIT 1},
        {Slice => {}},
        $entry_id
    )};
    return unless $entry;
    $entry->{ctime} = Time::Piece->new($entry->{ctime})->strftime('%Y-%m-%d(%a) %H:%M');
    return $entry;
}

sub insert {
    args my $class,
         my $title,
         my $body,
         my $format => {default => 'hatena'},
         my $c      => {default => c()},
         ;


    my $html = $class->format_entry(format => $format, body => $body);
    $c->dbh->insert(
        entry => {
            title  => $title || 'no title',
            body   => $body,
            html   => $html,
            format => $format,
            ctime  => time(),
            mtime  => time(),
        }
    );
}

sub format_entry {
    args my $class,
         my $body,
         my $format,
         ;

    given ($format) {
    when ('html') {
        return $body; # nop
    }
    when ('hatena') {
        return Blog::Formatter::Xatena->format($body);
    }
    default {
        die "unknown format: '$format'";
    }
    }
}

sub update {
    args my $class,
         my $title,
         my $body,
         my $format => {default => 'hatena'},
         my $entry_id,
         my $c      => {default => c()},
         ;

    my $html = $class->format_entry(format => $format, body => $body);

    $c->dbh->do_i(
        q{UPDATE entry SET }, {
            title  => $title,
            body   => $body,
            html   => $html,
            format => $format,
            mtime  => time(),
        }, q{ WHERE entry_id=}, $entry_id
    );
}

1;

