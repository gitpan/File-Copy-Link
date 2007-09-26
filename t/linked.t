#!perl
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl linked.t'

use strict;
use warnings;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 18;
BEGIN { use_ok('File::Spec::Link') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use Cwd ();
use File::Temp qw(tempdir);

chdir tempdir() or die;
my $dir = 'test';
mkdir $dir or die;

my $file = File::Spec->catfile($dir,'file.txt');
my $link = File::Spec->catfile($dir,'link.lnk');
my $loopx = File::Spec->catfile($dir,'x.lnk');
my $loopy = File::Spec->catfile($dir,'y.lnk');

open my $fh, ">", $file or die $!;
print $fh "text\n" or die;
close $fh or die;

SKIP: {
    skip "'symlink' not implemented", 17 unless eval{ symlink("",""); 1 }; 

    die unless
	symlink('file.txt',$link) &&
	symlink('y.lnk', $loopx) &&
	symlink('x.lnk', $loopy);

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

    mkdir $subdir or die;
    open $fh, ">", $target or die "$target - $!\n";
    print $fh "test\ntest\n" or die;
    close $fh or die;

    symlink( 'testdir', $linked ) or die;

    is( File::Spec->canonpath(File::Spec::Link->linked($linked)),
	File::Spec->canonpath($subdir), "linked - directory");
    is( File::Spec->canonpath(File::Spec::Link->resolve($linked)),
	File::Spec->canonpath($subdir), "resolve - directory");

    SKIP: {
	skip "Can't determine directory separator", 2
	    unless File::Spec->catdir('abc','xyz') =~ /\A abc (\W+) xyz \z/msx;
	my $sep = $1;

	is( File::Spec->canonpath(File::Spec::Link->linked($linked.$sep)),
	    File::Spec->canonpath($subdir), "linked - directory with $sep");
	is( File::Spec->canonpath(File::Spec::Link->resolve($linked.$sep)),
	    File::Spec->canonpath($subdir), "resolve - directory with $sep");
    }

    is( File::Spec->canonpath(File::Spec::Link->resolve($unresolved)),
	File::Spec->canonpath($unresolved), "resolve - embedded link");

    is( File::Spec->canonpath(File::Spec::Link->resolve_all($linked)),
	File::Spec->canonpath($subdir), "resolve_all - directory");
    is( File::Spec->canonpath(File::Spec::Link->resolve_all($unresolved)),
	File::Spec->canonpath($target), "resolve_all - file");

    is( File::Spec->canonpath(File::Spec::Link->resolve_all(
		File::Spec->catfile($dir,File::Spec->updir,$unresolved))),
	File::Spec->canonpath($target), "resolve_all - file");
    is( File::Spec->canonpath(File::Spec::Link->resolve_all(
		File::Spec->rel2abs($unresolved))),
	Cwd::abs_path($target), "resolve_all - file absolute");

    is( File::Spec->canonpath(File::Spec::Link->full_resolve($linked)),
	File::Spec->canonpath($subdir), "full_resolve - directory");
    is( File::Spec->canonpath(File::Spec::Link->full_resolve($unresolved)),
	File::Spec->canonpath($target), "full_resolve - file");

    is( File::Spec->canonpath(File::Spec::Link->resolve_path($linked)),
	File::Spec->canonpath($subdir), "resolve_path - directory");
    is( File::Spec->canonpath(File::Spec::Link->resolve_path($unresolved)),
	File::Spec->canonpath($target), "resolve_path - file");

}

# $Id: linked.t 82 2006-07-26 08:55:37Z rmb1 $
