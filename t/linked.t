# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl linked.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 11;
BEGIN { use_ok('File::Spec::Link') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use File::Path;

my $dir = 'test';
if( -e $dir ) { rmtree $dir or die }
mkpath $dir or die;

my $file = File::Spec->catfile($dir,'file.txt');
my $link = File::Spec->catfile($dir,'link.lnk');
my $loopx = File::Spec->catfile($dir,'x.lnk');
my $loopy = File::Spec->catfile($dir,'y.lnk');

open my $fh, ">", $file or die;
print $fh "text\n" or die;
close $fh or die;

ok( symlink('file.txt',$link) &&
	symlink('y.lnk', $loopx) &&
	symlink('x.lnk', $loopy), "create links");

is( File::Spec->canonpath(File::Spec::Link->linked($link)),
	File::Spec->canonpath($file), "linked - to file"); 
is( File::Spec->canonpath(File::Spec::Link->linked($loopx)),
	File::Spec->canonpath($loopy), "linked - to link"); 

is( File::Spec->canonpath(File::Spec::Link->resolve($link)),
	File::Spec->canonpath($file), "resolve - file"); 
ok( !defined(File::Spec::Link->resolve($loopx)), "resolve - loop"); 

my $subdir = File::Spec->catdir($dir,'testdir');
my $linked = File::Spec->catdir($dir,'linkdir');
my $target = File::Spec->catfile($subdir,'file.txt');
my $unresolved = File::Spec->catfile($linked,'file.txt');

mkpath $subdir or die;
open $fh, ">", $target or die "$target - $!\n";
print $fh "test\ntest\n" or die;
close $fh or die;

ok( symlink( 'testdir', $linked ), "create directory link");
is( File::Spec->canonpath(File::Spec::Link->resolve($linked)),
	File::Spec->canonpath($subdir), "resolve - directory");
is( File::Spec->canonpath(File::Spec::Link->resolve($unresolved)),
	File::Spec->canonpath($unresolved), "resolve - embedded link");
is( File::Spec->canonpath(File::Spec::Link->full_resolve($linked)),
	File::Spec->canonpath($subdir), "full_resolve - directory");
is( File::Spec->canonpath(File::Spec::Link->full_resolve($unresolved)),
	File::Spec->canonpath($target), "full_resolve - file");

END { rmtree $dir if $dir };
