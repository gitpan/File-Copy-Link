use 5.005;
use List::Util qw(sum);
require ExtUtils::MM;
 
sub build_args() {
  return (
   	module_name  =>	'File::Copy::Link',
	dist_version =>	sprintf("%.3f",
				sum map {MM->parse_version($_)}
					<lib/File/*/Link.pm>),
	license      =>	'perl',	
	requires     =>	{ File::Spec => 0, File::Copy => 0 }, 
	recommends   =>	{ Cwd => 2.18, },
	script_files =>	[ qw(copylink) ],
	dist_author  =>	'Robin Barker <rmb1@npl.co.uk>',
    );
}

1;

# $Id: build_args.pl 167 2007-12-28 22:03:18Z rmb1 $
