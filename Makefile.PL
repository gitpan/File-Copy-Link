# Created by Build.PL
use 5.006;
use strict;
use ExtUtils::MakeMaker;
my $args = {
          'PL_FILES' => {},
          'NAME' => 'File::Copy::Link',
          'AUTHOR' => 'Robin Barker <rmb1@npl.co.uk>',
          'EXE_FILES' => [
                           'copylink'
                         ],
          'VERSION' => '0.112',
          'PREREQ_PM' => {
                           'File::Copy' => 0,
                           'File::Spec' => 0
                         }
        };

WriteMakefile( %$args );
