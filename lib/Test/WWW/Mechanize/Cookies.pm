
sub Test::WWW::Mechanize::get_cookie {
	my ($mech, $cookie_name) = @_;

	# normally there will be only one domain in use...
	my $domain = [keys %{$mech->cookie_jar->{COOKIES}}]->[0];

	my $cookie = $mech->cookie_jar->{COOKIES}->{$domain}->{'/'}->{$cookie_name};

	return $cookie->[1];
}

sub Test::WWW::Mechanize::set_cookie {
	my ($mech, $cookie_name, $value) = @_;

	# normally there will be only one domain in use...
	my $domain = [keys %{$mech->cookie_jar->{COOKIES}}]->[0];

	my $cookie = $mech->cookie_jar->{COOKIES}->{$domain}->{'/'}->{$cookie_name};

	$cookie->[1] = $value;
}

1;
