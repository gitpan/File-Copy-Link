use 5.005;
use Module::Build;
use List::Util qw(sum);
 
Module::Build->new (
    dist_name	=>	'File-Copy-Link',
    dist_version =>	do{ require ExtUtils::MM;
			    sprintf("%.3f",
				sum map {MM->parse_version($_)}
					<lib/File/*/Link.pm>) },
    license =>		'perl',	
    requires =>		{ File::Spec => 0, File::Copy => 0 }, 
    script_files =>	[ qw(copylink) ],
    dist_author	=>	'Robin Barker <rmb1@npl.co.uk>',
    dist_abstract => 	<<'ABSTRACT',	# from File::Copy::Link
Perl extension for replacing a link by a copy of the linked file.
ABSTRACT
    create_makefile_pl => 'traditional'
)
 -> create_build_script;

# $Id: Build.PL 146 2007-09-26 12:04:57Z rmb1 $
