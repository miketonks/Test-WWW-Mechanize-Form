
use Test::XPath;
use XML::XPath;

sub Test::WWW::Mechanize::xpath_ok
{
	my ($mech, $path, $value, $desc) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $html = $mech->content;

	my $xpath = Test::XPath->new( xml => $html, is_html => 1 );

	return $xpath->ok($path, $value, $desc);
}

sub Test::WWW::Mechanize::xpath_not_ok
{
	my ($mech, $path, $value, $desc) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $html = $mech->content;

	my $xpath = Test::XPath->new( xml => $html, is_html => 1 );

	return $xpath->not_ok($path, $value, $desc);
}

sub Test::WWW::Mechanize::xpath_is
{
	my ($mech, $path, $value, $desc) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $html = $mech->content;

	my $xpath = Test::XPath->new( xml => $html, is_html => 1 );

	return $xpath->is($path, $value, $desc);
}

sub Test::WWW::Mechanize::xpath_is_not
{
	my ($mech, $path, $value, $desc) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $html = $mech->content;

	my $xpath = Test::XPath->new( xml => $html, is_html => 1 );

	return $xpath->isnt($path, $value, $desc);
}

sub Test::WWW::Mechanize::xpath_like
{
	my ($mech, $path, $value, $desc) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $html = $mech->content;

	my $xpath = Test::XPath->new( xml => $html, is_html => 1 );

	return $xpath->like($path, $value, $desc);
}

sub Test::WWW::Mechanize::xpath_get
{
	my ($mech, $path) = @_;

	my $html = $mech->content;

	#my $xpath = XML::XPath->new(xml => $html);
	my $xpath = Test::XPath->new( xml => $html, is_html => 1 );

	# I'm a bit lost here but this seems to work
	my $nodelist = $xpath->{xpc}->findnodes($path);

	my $result = '';

	foreach my $node ($nodelist->get_nodelist) {

    	$result .= $node->toString();
	}

	$result =~ s/&#13;/\n/g; # why does it corrupt the line endings?

	return $result;

	#return $result->string_value();
	#return $result;
}

1;
