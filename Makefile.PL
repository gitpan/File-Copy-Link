use 5.005;
use ExtUtils::MakeMaker;
 
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME		=> 'File::Copy::Link',
    VERSION_FROM	=> 'lib/File/Spec/Link.pm', # finds $VERSION
    PREREQ_PM		=> {File::Spec => 0, File::Copy => 0}, 
    EXE_FILES		=> [qw(copylink)],
    AUTHOR	     	=> 'Robin Barker <rmb1@npl.co.uk>',
);
