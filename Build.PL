use 5.005;
use Module::Build;
use List::Util qw(sum);
 
Module::Build->new (
    module_name	=>	'File::Copy::Link',
    dist_version =>	do{ require ExtUtils::MM;
			    sprintf("%.2f",
				sum map {MM->parse_version($_)}
					<lib/File/*/Link.pm>) },
    license =>		'perl',	
    requires =>		{ File::Spec => 0, File::Copy => 0 }, 
    script_files =>	[ qw(copylink) ],
    dist_author	=>	'Robin Barker <rmb1@npl.co.uk>',
    create_makefile_pl => 'traditional'
)
 -> create_build_script;
