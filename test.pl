#!/usr/bin/perl

use strict;

use TimUtil;
use TimObj;

parse_args();

my $obj = TimObj->new();

$obj->init();

$obj->show_self();

