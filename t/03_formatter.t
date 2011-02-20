use strict;
use warnings;
use utf8;
use Test::More;
use Blog::Formatter::Xatena;

is(trim(Blog::Formatter::Xatena->format(<<'---')), trim(<<'==='));
foo
>||
bar
||<
---
<p>foo</p>
<pre class="code">bar</pre>
===

is(trim(Blog::Formatter::Xatena->format(<<'---')), trim(<<'==='));
L<Foo>
---
<p><a href="http://frepan.org/perldoc?Foo">Foo</a></p>
===

is(trim(Blog::Formatter::Xatena->format(<<'---')), trim(<<'==='));
Dan::Kogai
---
<p><a href="http://frepan.org/perldoc?Dan%3A%3AKogai">Dan::Kogai</a></p>
===

is(trim(Blog::Formatter::Xatena->format(<<'---')), trim(<<'==='));
@tokuhirom
---
<p><a href="http://twitter.com/tokuhirom">@tokuhirom</a></p>
===

done_testing;

sub trim { local $_ = shift; s/\n$//; $_ }

