package File::Spec::Link;

use strict;
use warnings;

use File::Spec ();
our @ISA = qw(File::Spec);
our $VERSION = '0.02';

sub linked { 
    my($spec, $link) = @_;
    my $read = readlink $link;
    return unless defined $read;
    return $spec->relative_to_file($read,$link);
}
 
sub relative_to_file {
    my($spec, $path, $file) = @_;
    return $path if $spec->file_name_is_absolute($path);
    return unless defined(my $dir = $spec->chopfile($file));
    return $spec->catdir($dir,$path);
}

sub chopfile {
    my($spec, $file) = @_;
    my($vol, $dir) = $spec->splitpath($file);	# discard file component
    return $spec->catpath($vol, $dir, '') if $vol;	# UNIX short cut
    return $dir if $dir;
    return $spec->curdir;
}

sub resolve {
    my($spec, $file) = @_;
    my %seen;
    while( -l $file ) {
	return if $seen{$spec->canonpath($file)}++;
	return unless defined($file = $spec->linked($file));
    }
    return $file;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

File::Spec::Link - Perl extension for reading and resolving symbolic links

=head1 SYNOPSIS

    use File::Spec::Link;
    my $file = File::Spec::Link->linked($link); 
    my $file = File::Spec::Link->resolve($link); 
    my $dirname = File::Spec::Link->chopfile($file);
    my $newname = File::Spec::Link->relative_to_file($path, $link);
  
=head1 DESCRIPTION

C<File::Spec::Link> is an extension to C<File::Spec>, adding methods for
resolving symbolic links; it was created to implement C<File::Copy::Link>.

=over

=item C<< ->linked($link) >>

Returns the filename linked to by <$link>: by C<readlink>ing C<$link>,
and resolving that path relative to the directory of C<$link>. 

=item C<< ->resolve($link) >>

Returns the non-link ultimately linked to by <$link>, by repeatedly
calling C<linked>.  Returns C<undef> if the link can not be resolved.

=item C<< ->chopfile($file) >>

Returns the directory of C<$file>, by splitting the path of C<$file>
and returning (the volumne and) directory parts.

=item C<< ->relative_to_file($path, $file) >>

Returns the path of C<$path> relative to the directory of file
C<$file>.  If C<$path> is absolute, just returns C<$path>.

=back
 
=head2 EXPORT

None - all subs are class methods for C<File::Spec::Link>.

=head1 SEE ALSO

File::Spec(3) File::Copy::Link(3)

=head1 AUTHOR

Robin Barker, E<lt>Robin.Barker@npl.co.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Robin Barker

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
