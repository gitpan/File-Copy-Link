use 5.005;
use ExtUtils::MakeMaker;
use List::Util qw(sum);
 
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME	=> 'File::Copy::Link',
    VERSION	=> sprintf("%.2f",
			sum map {MM->parse_version($_)}
					<lib/File/*/Link.pm>),
    PREREQ_PM	=> {File::Spec => 0, File::Copy => 0}, 
    EXE_FILES	=> [qw(copylink)],
    AUTHOR	=> 'Robin Barker <rmb1@npl.co.uk>',
);
