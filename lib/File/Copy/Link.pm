package File::Copy::Link;

use strict;
use Carp;
use File::Copy ();
use File::Spec::Link ();

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(copylink);
our $VERSION = '0.01';

sub copylink(;$) {
    local $_ = @_ ? shift : $_;			# default to $_ 
    croak "$_ not a link\n" unless -l;
    my $orig = File::Spec::Link->linked($_);
    croak "$_ link problem\n" unless defined $orig;
    unlink or croak "Can't unlink link $_: $!\n";
    File::Copy::copy $orig, $_ or croak "copy($orig $_) failed: $!\n";
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

File::Copy::Link - Perl extension for replacing a link by a copy of the
linked file.

=head1 SYNOPSIS

  use File::Copy::Link;
  copylink 'file.lnk'; 

=head1 DESCRIPTION

C<copylink> reads the filename linked to by the argument and replaced 
the link with a copy of the file.

This module is mostly a wrapper round C<File::Spec::Link::linked> and 
C<File::Copy::copy>, the functionality is available in a command line
script F<copylink>.
 
=head2 EXPORT

C<copylink> - only sub defined 

=head1 SEE ALSO

copylink(1) File::Copy(3) File::Spec::Link(3)

=head1 AUTHOR

Robin Barker, E<lt>Robin.Barker@npl.co.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Robin Barker

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
