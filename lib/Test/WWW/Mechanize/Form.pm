
package Test::WWW::Mechanize::Form;

use strict;

=head1 NAME

Test::WWW::Mechanize::Form - extensions to Test::WWW:Mechanize using additional methods from HTML Form 

=head1 DESCRIPTION

Exports methods directly into the Test::WWW::Mechanize namespace, allowing these to be used with any of the many subclasses e.g Test::WWW::Mechanize::PSGI or Test::WWW::Mechanize::CGIApp

=head1 SYNOPSIS

  use Test::WWW::Mechanize;
  use Test::WWW::Mechanize::Form;

  my $mech = Test::WWW::Mechanize->new;
  $mech->get_ok( $page );

  $mech->form_field_value_matches('Name', 'Wild Joe', 'testform', 'Name matched');

=cut

use Test::HTML::Form qw/form_field_value_matches form_select_field_matches/;

=head1 FUNCTIONS

=head2 form_field_value_matches (method)

parameters:
  field_name
  field_value
  form_name
  desc

Compare given value to the value of a html text input.  Return true if exact match, otherwise false.

=cut

sub Test::WWW::Mechanize::form_field_value_matches
{
	my ($mech, $field_name, $field_value, $form_name, $desc) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	# from Test::HTML::Form: ...
	return form_field_value_matches($mech->response, $field_name, $field_value, $form_name, $desc);
}

=head2 form_select_field_matches

parameters:
  field_name
  field_value
  form_name
  desc

alternative parameters:
  params
  desc

where params is a hash ref: { field_name => ..., selected => ..., form_name => ... } as per Test::HTML::Form

Compare value to the selected item in a html select input (drop down).

=cut

sub Test::WWW::Mechanize::form_select_field_matches
{
	my ($mech, $params, $desc) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	# handle params passed in the non-hashref form_field_value_matches style
	unless (ref($params)) {

		my ($field_name, $field_value, $form_name);

		($mech, $field_name, $field_value, $form_name, $desc) = @_;

		$params = { field_name => $field_name, selected => $field_value, form_name => $form_name };
	}

	return form_select_field_matches($mech->response, $params, $desc);
}

=head2 form_select_field_contains

parameters:
  field_name
  field_value
  form_name
  desc

alternative parameters as per form_select_field_matches

Check the form contains a select field with given value available in the list of options, i.e. value is a valid selection but not necessarily selected.

=cut

sub Test::WWW::Mechanize::form_select_field_contains
{
	my ($mech, $params, $desc) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my ($form_name, $field_name, $field_value);

	if (ref($params)) {

		$field_value = $params->{selected};
		$field_name = $params->{field_name};
	}
	else { # handle params passed in the non-hashref form_field_value_matches style

		($mech, $field_name, $field_value, $form_name, $desc) = @_;
	}

	my $form_fields = Test::HTML::Form->get_form_values({filename => $mech->response, form_name => $form_name});

	my $select_elem = $form_fields->{$field_name}[0];

	unless (UNIVERSAL::can($select_elem,'descendants')) {
		die "$select_elem (",$select_elem->tag,") is not a select html element for field : $field_name - did you mean to call form_checkbox_field_matches ?";
	}

	my $found;

	my @descendants = $select_elem->descendants;

	foreach my $option ( @descendants ) {

		next unless (ref($option) && ( lc($option->tag) eq 'option') );

		if ( Test::HTML::Form::_compare($option, $field_value) ) {

			$found = $option;
			last;
		}
	}

	my $ok = ok($found, $desc);

	unless ($ok) {
		diag("Expected form to contain field '$field_name' and have an option with possible value of '$field_value' but value not found select options \n");
	}
	return $ok;
}

=head2 form_checkbox_field_matches

parameters:
  field_name
  field_value
  form_name
  desc

Check the form contains a checkbox field with given value and that the checkbox is checked.

=cut

sub Test::WWW::Mechanize::form_checkbox_field_matches
{
	my ($mech, $field_name, $field_value, $form_name, $desc) = @_;

	# original Test::HTML::Form method doesn't handle 'not checked' values

	#form_checkbox_field_matches($mech->response, $params, $desc);

	my $form_elements = Test::HTML::Form->get_form_values({filename => $mech->response, form_name => $form_name});

	my $form_element = $form_elements->{$field_name};

#warn "ELEMENT: " . Dumper($form_element);

	if (!$form_element) {

		Test::HTML::Form->builder->ok(0, $desc);
		Test::HTML::Form->builder->diag("Field $field_name not found in form $form_name");
	}
	elsif (scalar @$form_element == 1) {

		my $checkbox_value 	= $form_element->[0]->attr('value');
		my $checkbox_checked = $form_element->[0]->attr('checked');

		if ($checkbox_checked && $field_value eq $checkbox_value) {

			Test::HTML::Form->builder->ok(1, $desc);
		}
		elsif (!$field_value && !$checkbox_checked) { # this is the unchecked case

			Test::HTML::Form->builder->ok(1, $desc);
		}
		elsif ($checkbox_checked) {

			Test::HTML::Form->builder->ok(0, $desc);
			Test::HTML::Form->builder->diag("Field $field_name is checked but got value: $checkbox_value, expected: $field_value");
		}
		elsif (!$checkbox_checked && $field_value eq $checkbox_value) {

			Test::HTML::Form->builder->ok(1, $desc);
			Test::HTML::Form->builder->diag("Field $field_name is has value: $checkbox_value, but is not checked");
		}
		else {

			Test::HTML::Form->builder->ok(0, $desc);
			Test::HTML::Form->builder->diag("Field $field_name is not checked, and got value: $checkbox_value, expected: $field_value");
		}
	}
	else {

		$form_elements->{$field_name} = 'ARRAY'; # TODO Handle this and return arrayref of values
	}

}

=head2 get_form_value

parameters:
  field
  form_name

Return the current value of the given field.

=cut

sub Test::WWW::Mechanize::get_form_value
{
	my ($mech, $field, $form_name) = @_;

	my $form_values = $mech->get_form_values($form_name);

	if (ref($form_values->{$field}) eq 'ARRAY') {

		if (scalar @{$form_values->{$field}} == 0) {
			return('');
		} elsif (scalar @{$form_values->{$field}} == 1) {
			return shift @{$form_values->{$field}};
		} else {
			return($form_values->{$field});
		}
	}

	return $form_values->{$field};
}

=head2 get_form_values

Return all of the current field data from the form, as a hashref.

=cut

sub Test::WWW::Mechanize::get_form_values
{
	my ($mech, $form_name) = @_;

	my $form_elements = Test::HTML::Form->get_form_values({filename => $mech->response, form_name => $form_name});

	my $simple_form_elements = {};

	#simplify return values
	foreach my $field (keys %$form_elements) {
		my $form_element = $form_elements->{$field};

		if (scalar @$form_element == 1) {

			# special case for select elements
			if ($form_element->[0]->tag eq 'select') {
				my $selected_option;

				foreach my $option ( $form_element->[0]->content_list() ) {
					if (ref($option) ne 'HTML::Element') {
						next;
					}

					if ($option->tag eq 'option') {
						if ($option->{selected}) {
							push(@$selected_option, $option->{value});
						}
					} else {
						next;
					}
				}

				if ($selected_option) {
					$simple_form_elements->{$field} = $selected_option;
				} else {
					# No option is selected, do as the default submission of the form would do and take the first value in the list
					my @options = $form_element->[0]->content_list();
					my $option;

					foreach my $test (@options) {
						if (ref($test) eq 'HTML::Element') {
							$option = $test;
							last;
						}
					}

					$simple_form_elements->{$field} = $option->{value};
				}
			}
			else {

				my $value = $form_element->[0]->attr('value');

				unless (defined $value) {

					$value = $form_element->[0]->as_trimmed_text; # returns incorrect string of combined display values for select boxes
				}

				$simple_form_elements->{$field} = $value;
			}
		}
		else {

			$simple_form_elements->{$field} = 'ARRAY'; # TODO Handle this and return arrayref of values
		}
	}

	return $simple_form_elements;
}

=head2 enable_field

Enable and make writable the given field, i.e. if either the readonly or disabled attributes are set.

=cut

sub Test::WWW::Mechanize::enable_field
{
	my ($mech, $field_name) = @_;

	my $form = $mech->current_form or $mech->die( 'No form defined' );

	my $field = $form->find_input($field_name);

	$field->readonly(0);

	$field->disabled(0);
}

1;
