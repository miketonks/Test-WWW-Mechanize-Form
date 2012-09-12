
use inc::Module::Install;
  
# Define metadata
name           'Test-WWW-Mechanize-Form';
#all_from       'lib/Test/WWW/Mechanize/Form.pm';

author        'Mike Tonks <miket@cpan.org>';
version       '0.1';
license       'perl';
 
# Specific dependencies
requires       'Test::More'  => 0;
requires       'Test::WWW::Mechanize'  => 0;

WriteAll;
