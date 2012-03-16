# -*- mode: cperl -*-
# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

package EDG::WP4::CCM::JSONProfile;

=pod

=head1 SYNOPSIS

    EDG::WP4::CCM::XMLPanProfile->interpret_node($tag, $xmltree);

=head1 DESCRIPTION

Module that iterprets an XML profile in C<pan> format, and generates
all the needed metadata, to be inserted in the cache DB.

This metadata includes a checksum for each element in the profile, the
Pan basic type, the element's name (that will help to reconstruct the path)...

Should be used by C<EDG::WP4::CCM::Fetch> only.

This module has only one method for the outside world:

=cut

use strict;
use warnings;
use EDG::WP4::CCM::Fetch qw(ComputeChecksum);
use JSON::XS;

$SIG{__DIE__} = \&confess;


# Warns in case a tag in the XML profile is not known (i.e, has not a
# valid entry in the INTERPRETERS hash.
sub warn_unknown
{
    my ($content, $tag) = @_;

    warn "Cannot handle tag $tag!";
}


# Turns an nlist in the XML into a Perl hash reference with all the
# types and metadata from the profile.
sub interpret_nlist
{
    my ($class, $tag, $content) = @_;

    my $nl = {};

    my $h;


    while (my ($k, $v) = each(%$content)) {
	$nl->{$k} = $class->interpret_node($k, $v);
    }
    return $nl;
}


# Turns a list in the profile into a perl array reference in which all
# the elements have the correct metadata associated.
sub interpret_list
{
    my ($class, $tag, $doc) = @_;

    my $l = [];

    foreach my $i (@$doc) {
	push(@$l, $class->interpret_node($tag, $i));
    }

    return $l;
}

=pod

=head2 C<interpret_node>

Interprets an XML tree, which is assumed to have a C<format="pan">
attribute, returning the appropriate data structure with all the
attributes and values.

=cut

sub interpret_node
{
    my ($class, $tag, $doc) = @_;

    my $r = ref($doc);

    my $v = {NAME => $tag};
    if (!$r) {
	# Perl loses all the basic type information. All we can
	# recover is if it is a boolean or not. The rest will be
	# handled as strings, which is how they will be stored in the
	# profile, anyways. It is harmless from the component's point
	# of view, but it won't produce identical caches as what we
	# get from the XMLs.
	if (JSON::XS::is_bool($doc)) {
	    $v->{TYPE} = "boolean";
	    $v->{VALUE} = $doc ? "true" : "false";
	} else {
	    $v->{VALUE} = $doc;
	    $v->{TYPE} = 'string';
	}
    } elsif ($r eq 'HASH') {
	$v->{TYPE} = 'nlist';
	$v->{VALUE} = $class->interpret_nlist($tag, $doc);
    } elsif ($r eq 'ARRAY') {
	$v->{TYPE} = 'list';
	$v->{VALUE} = $class->interpret_list($tag, $doc);
    }
    $v->{CHECKSUM} = ComputeChecksum($v);
    return $v;
}

1;