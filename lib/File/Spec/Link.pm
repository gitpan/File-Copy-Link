package File::Spec::Link;

use strict;
use warnings;

use File::Spec ();
our @ISA = qw(File::Spec);
our $VERSION = '0.04';

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

sub splitlast {
    my($spec, $dir) = @_;
    my @path = $spec->splitdir($dir);
    my $found = scalar @path;
    while( --$found ) { last if length $path[$found] } 
    return ($spec->catdir(@path[0..$found-1]), $path[$found]);
}

sub chopfile {
    my($spec, $file) = @_;
    my($vol, $dir);
    ($vol, $dir, $file) = $spec->splitpath($file);	
						# discard file component
    unless( length $file ) {
	($dir, $file) = $spec->splitlast($dir);
	die unless length $file;
    }
    return $spec->catpath($vol, $dir, '')	if length $vol;
    return $dir					if length $dir;
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

sub full_resolve {
    my($spec, $file) = @_;
    my $path = $spec->resolve_path($file);
    return defined $path ? $path : $spec->resolve_all($file);
}

sub resolve_path {
    my($spec, $file) = @_;
    my $path = eval { require Cwd; Cwd::abs_path($file) };
    return unless defined $path; 
    return $spec->file_name_is_absolute($file)
	    ? $path : $spec->abs2rel($path);
} 
    
sub resolve_all {
    my($spec, $file) = @_;
    my %seen;
    while( -l $file ) {
	return if $seen{$spec->canonpath($file)}++;
	return unless defined($file = $spec->linked($file));
    }
    my($vol, $dir, @temp);
    ($vol, $dir, $file) = $spec->splitpath($file);
    while( length $dir ) {
	my $path = $spec->catpath($vol, $dir, '');
	if( -l $path ) {
	    return if $seen{$spec->canonpath($path)}++;
	    return unless defined($path = $spec->linked($path));
            ($vol, $dir) = $spec->splitpath($path, 1);
	}
	else {
            ($dir, my $last) = $spec->splitlast($dir);	
	    unshift @temp, $last;
	}
    }
    my @path;
    for my $path (@temp) {
 	if( $path eq $spec->curdir ) { next if @path } 
	elsif( $path eq $spec->updir ) {
	    if( @path and $path[-1] ne $spec->updir ) {
		pop @path; next 
	    }
	}
	push @path, $path
    }	
    $spec->catpath($vol, $spec->catdir(@path), $file);
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
  
    my $realname = File::Spec::Link->full_resolve($file);
    my $realname = File::Spec::Link->resolve_path($file);
    my $realname = File::Spec::Link->resolve_all($file);

=head1 DESCRIPTION

C<File::Spec::Link> is an extension to C<File::Spec>, adding methods for
resolving symbolic links; it was created to implement C<File::Copy::Link>.

=over

=item C<< ->linked($link) >>

Returns the filename linked to by C<$link>: by C<readlink>ing C<$link>,
and resolving that path relative to the directory of C<$link>. 

=item C<< ->resolve($link) >>

Returns the non-link ultimately linked to by C<$link>, by repeatedly
calling C<linked>.  Returns C<undef> if the link can not be resolved.

=item C<< ->chopfile($file) >>

Returns the directory of C<$file>, by splitting the path of C<$file>
and returning (the volumne and) directory parts.

=item C<< ->relative_to_file($path, $file) >>

Returns the path of C<$path> relative to the directory of file
C<$file>.  If C<$path> is absolute, just returns C<$path>.

=item C<< ->resolve_all($file) >>

Returns the filename of C<$file> with all links in the path resolved,
wihout using C<Cwd>.

=item C<< ->full_resolve($file) >>

Returns the filename of C<$file> with all links in the path resolved.

This sub tries to use C<Cwd::abs_path> via C<< ->resolve_path >>.

=item C<< ->resolve_path($file) >>

Returns the filename of C<$file> with all links in the path resolved.

This sub uses C<Cwd::abs_path> and is independent of the rest of
C<File::Spec::Link>. 

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
