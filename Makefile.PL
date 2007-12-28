use ExtUtils::MakeMaker;
require	'build_args.pl';
our %build_args = build_args();

WriteMakefile
(
	PL_FILES	=> {},
	INSTALLDIRS	=> 'site',
    	AUTHOR		=> $build_args{dist_author},
	VERSION		=> $build_args{dist_version},
	NAME		=> $build_args{module_name},
	PREREQ_PM	=> $build_args{requires},
	EXE_FILES	=> $build_args{script_files},
);

# $Id: Build.PL 166 2007-12-28 19:57:22Z rmb1 $
