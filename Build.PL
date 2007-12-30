use 5.006;
use Module::Build();
use Data::Dumper ();
use List::Util qw(sum);
use ExtUtils::MM ();
 
my %args = (
   	module_name	=> 'File::Copy::Link',
	dist_version	=> sprintf("%.3f",
				sum map {MM->parse_version($_)}
					<lib/File/*/Link.pm>),
	license		=> 'perl',	
	requires	=> { File::Spec => 0, File::Copy => 0 }, 
	recommends	=> { Cwd => 2.18, },
	script_files	=> [ qw(copylink) ],
	dist_author  	=> 'Robin Barker <rmb1@npl.co.uk>',
	build_requires  => { Test::More => 0, File::Temp => 0 }, 
    );

Module::Build -> new ( %args ) -> create_build_script;

my $file = 'Makefile.PL';
if( open OUT, '>', $file ) {

    my $make = { 
	NAME		=> $args{module_name},
	VERSION		=> $args{dist_version},
	AUTHOR		=> $args{dist_author},
	PREREQ_PM	=> $args{requires},
	EXE_FILES	=> $args{script_files},
	PL_FILES	=> {}
    };
    my $dump = Data::Dumper->Dump( [$make], [qw(args)] );

    print OUT <<MAKEFILE or die "Can't print to $file: $!";
# Created by Build.PL
use 5.006;
use strict;
use ExtUtils::MakeMaker;
my $dump
WriteMakefile( \%\$args );
MAKEFILE

    close OUT or die "Error closing $file: $!";
    warn "Wrote $file\n";
}
else {
    warn "Can't write to $file: $!"
	unless $! == 13;	# Permission dened
}

# $Id: Build.PL 174 2007-12-30 15:54:41Z rmb1 $
    
