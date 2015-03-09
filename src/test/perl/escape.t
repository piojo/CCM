#!/usr/bin/perl
# -*- mode: cperl -*-
use strict;
use warnings;

use Test::More;
use CAF::FileReader;
use JSON::XS qw(decode_json);
use Test::Deep;
use File::Path qw(make_path);
use EDG::WP4::CCM::Element qw(escape unescape);

=pod

=head1 SYNOPSIS

Tests for the escape/unescape methods.

=cut


sub compile_profile
{
    make_path('target/test/json');
    system("cd src/test/resources && panc --formats json --output-dir ../../../target/test/json escape.pan");
}



=pod

The test is trivial: compile a pan template to json; the templates consists of C<"/{value}" = "value";>

=cut

compile_profile();
my $fh = CAF::FileReader->new("target/test/json/escape.json");
note("Profile contents: $fh");
my $t = decode_json("$fh");
note("Tree=", explain($t));

while (my ($esc, $value) = each %$t ) {
    is(unescape($esc), $value, "Unescape escaped value '$value'");
    is(escape($value), $esc, "Escape value '$value'");
    is(unescape(escape($value)), $value, "escape(unescape()) identity test value '$value'");
    is(escape(unescape($esc)), $esc, "unescape(escape()) identity test value '$value'");
}

done_testing();