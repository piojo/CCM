#!/usr/bin/perl
# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;

use constant MODULES => qw(Fetch CCfg Configuration Path SyncFile
			   CacheManager Resource Element Stream
			   Property DB XMLPanProfile JSONProfile
			   XMLDBProfile);

plan tests => scalar(MODULES);

foreach my $i (MODULES) {
    use_ok("EDG::WP4::CCM::$i");
}
