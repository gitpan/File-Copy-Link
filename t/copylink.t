# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl copylink.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 11;
BEGIN { use_ok('File::Copy::Link') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use File::Compare;
use File::Path;

my $dir = 'test';
if( -e $dir ) { rmtree $dir or die }
mkpath $dir or die;

my $file = File::Spec->catfile($dir,'file.txt');
my $link = File::Spec->catfile($dir,'link.lnk');

open my $fh, ">", $file or die;
print $fh "text\n" or die;
close $fh or die;

ok( symlink('file.txt',$link), "create link");
ok( -l $link, "is a link");
ok( !compare($file,$link), "compare file and link");

open $fh, ">>", $file or die;
print $fh "more\n" or die;
close $fh or die;
ok( !compare($file,$link), "compare changed file and link");

ok( copylink($link), "copylink");
ok( !(-l $link), "not a link");
ok( !compare($file,$link), "compare file and copy");

open $fh, ">>", $file or die;
print $fh "more\n" or die;
close $fh or die;

ok( compare($file,$link), "compare changed file and copy");
unlink $file or die;
ok( -e $link, "copy not deleted"); 
unlink $link or die;
ok( !(-e $link), "copy deleted");

END { rmtree $dir if $dir };
