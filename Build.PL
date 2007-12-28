use Module::Build;
require 'build_args.pl';
Module::Build->new ( build_args() ) -> create_build_script;

# $Id: Build.PL 167 2007-12-28 22:03:18Z rmb1 $
