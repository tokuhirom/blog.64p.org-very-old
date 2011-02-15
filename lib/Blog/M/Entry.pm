use strict;
use warnings;
use utf8;
use 5.12.2;

package Blog::M::Entry;
use Amon2::Declare;
use Smart::Args;

sub search {
    args my $class,
         my $entries_per_page,
         my $current_page,
         my $c => {default => c()},
         ;

    my $entries = $c->dbh->selectall_arrayref(
        q{SELECT entry_id, title, body as html, mtime FROM entry ORDER BY entry_id DESC LIMIT ? OFFSET ?},
        {Slice => {}},
        $entries_per_page + 1,
        $entries_per_page * ($current_page-1),
    );
    my $has_next = ( $entries_per_page + 1 == @$entries );
    if ($has_next) { pop @$entries }
    return ($entries, $has_next);
}

sub retrieve {
    args my $class,
         my $entry_id,
         my $c      => {default => c()},
         ;

    my ($entry) = @{$c->dbh->selectall_arrayref(
        q{SELECT entry_id, title, body, html, mtime FROM entry WHERE entry_id=? ORDER BY entry_id DESC LIMIT 1},
        {Slice => {}},
        $entry_id
    )};
    return $entry;
}

sub insert {
    args my $class,
         my $title,
         my $body,
         my $format => {default => 'hatena'},
         my $c      => {default => c()},
         ;

    my $html;
    given ($format) {
    when ('html') {
        $html = $body; # nop
    }
    default {
        die "unknown format: '$format'";
    }
    }

    $c->dbh->insert(
        entry => {
            title  => $title,
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

