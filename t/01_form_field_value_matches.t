#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use Test::WWW::Mechanize;
use Test::WWW::Mechanize::Form;

use URI::file;

my $mech = Test::WWW::Mechanize->new( autocheck => 0 );
isa_ok($mech,'Test::WWW::Mechanize');

my $form_url = URI::file->new_abs( '../t/01_test_form_filled.html' )->as_string;

$mech->get_ok($form_url);

$mech->form_field_value_matches('Name', 'Wild Joe', 'testform', 'field: Name matched');

$mech->form_field_value_matches('Age', '1 1/2', 'testform', 'field: Age matched');

$mech->form_select_field_matches('FavoriteFood', 'bananas', 'testform', 'field: FavoriteFood matched');

$mech->form_select_field_matches({ field_name => 'FavoriteFood', selected => 'bananas', form_name => 'testform' }, 'field: FavoriteFood matched (alt syntax)');

$mech->form_checkbox_field_matches('CanWalk', undef, 'testform', 'field: CanWalk matched (not checked)');

$mech->form_checkbox_field_matches('CanRideBike', 'yes', 'testform', 'field: CanRideBike matched (checked)');





