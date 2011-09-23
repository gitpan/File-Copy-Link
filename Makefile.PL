# Created by Build.PL
use 5.006;
use strict;
use ExtUtils::MakeMaker;
my $args = {
          'PL_FILES' => {},
          'NAME' => 'File::Copy::Link',
          'AUTHOR' => 'Robin Barker <rmbarker@cpan.org>',
          'EXE_FILES' => [
                           'copylink'
                         ],
          'VERSION' => '0.113',
          'PREREQ_PM' => {
                           'File::Copy' => 0,
                           'File::Spec' => 0
                         }
        };

WriteMakefile( %$args );
