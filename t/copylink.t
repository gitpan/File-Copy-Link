#!perl
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl copylink.t'

use strict;
use warnings;
our $VERSION = 1.0;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 6;
BEGIN { use_ok('File::Copy::Link', qw(copylink) ) };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use File::Compare;
use File::Temp qw(tempdir);

my $dir = tempdir;

my $file = File::Spec->catfile($dir,'file.txt');
my $link = File::Spec->catfile($dir,'link.lnk');

open my $fh, q{>}, $file or die;
print {$fh} "text\n" or die;
close $fh or die;

SKIP: {
    if( !eval{ (symlink q{}, q{}), 1 } ) { 
	skip q{'symlink' not implemented}, 5 
    }
    # die if not((symlink 'file.txt', $link) and (-l $link) and not(compare($file,$link)));
    die $! if not(symlink 'file.txt', $link);
    die if not(-l $link); 
    die if compare($file,$link);

    open $fh, q{>>}, $file or die;
    print {$fh} "more\n" or die;
    close $fh or die;
    not compare($file,$link) or die;

    ok( copylink($link), q{copylink});
    ok( !(-l $link), q{not a link});
    ok( !compare($file,$link), q{compare file and copy});

    open $fh, q{>>}, $file or die;
    print {$fh} qq{more\n} or die;
    close $fh or die;

    compare($file,$link) or die;
    unlink $file or die;

    ok( -e $link, q{copy not deleted}); 
    unlink $link or die;
    ok( !(-e $link), q{copy deleted});
}

# $Id: copylink.t 82 2006-07-26 08:55:37Z rmb1 $
