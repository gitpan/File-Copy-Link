package File::Spec::Link;

use strict;
use warnings;

use File::Spec ();
our @ISA = qw(File::Spec);
our $VERSION = 0.04_1;

# over-ridden class method - just a debugging wrapper
# 
sub canonpath { 
    my($spec, $path) = @_;
    return $spec->SUPER::canonpath($path) if $path;
    require Carp;
    Carp::cluck( "canonpath: ", 
		defined $path ? "empty path" : "path undefined"  
    );
    return $path;
}
sub catdir { my $spec = shift; @_ ? $spec->SUPER::catdir(@_) : $spec->curdir }

# new class methods - implemented via objects
# 
sub linked { 
    my $self = shift -> new(@_); 
    return unless $self -> follow; 
    $self -> path; 
}
sub resolve { 
    my $self = shift -> new(@_); 
    return unless $self -> resolved; 
    $self -> path; 
}
sub resolve_all { 
    my $self = shift -> new(@_); 
    return unless $self -> resolvedir; 
    $self -> path; 
}
sub relative_to_file { 
    my($spec, $path) = splice @_, 0, 2;
    my $self = $spec -> new(@_); 
    return unless $self -> relative($path);
    $self -> path;
}
sub chopfile {
    my $self = shift -> new(@_);
    return $self -> path if length($self -> chop); 
}

# other new class methods - implemented via Cwd
# 
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

# old class method - not needed
# 
sub splitlast { 
    my $self = shift -> new(@_);
    my $last = $self -> chop;
    return ($self -> path, $last);
}

# object methods: 
# 	constructor methods	new
# 	access methods		path, canonical, vol, dir 
# 	updating methods	add, pop, push, split, chop
# 				relative, follow, resolved, resolvedir  

sub new { 
    my $self = bless { }, shift; 
    $self -> split(shift) if @_; 
    $self; 
}
sub path { 
    my $self = shift; 
    $self -> catpath( $self->vol, $self->dir, '' ); 
}
sub canonical { my $self = shift; $self -> canonpath( $self -> path ); }
sub vol { my $vol = shift->{vol}; return defined $vol ? $vol : '' } 
sub dir { my $self = shift; $self -> catdir( $self -> dirs ); }
sub dirs { my $dirs = shift->{dirs}; return $dirs ? @$dirs : () }
	
sub add {
    my($self, $file) = @_;
    if( $file eq $self -> curdir ) { }
    elsif( $file eq $self -> updir ) { $self -> pop }
    else { $self -> push($file); }
}
sub pop {
    my $self = shift;
    my @dirs = $self -> dirs;
    if( !@dirs or $dirs[-1] eq $self -> updir ) {
	push @{$self->{dirs}}, $self -> updir;
    }
    elsif( length $dirs[-1] and $dirs[-1] ne $self -> curdir) {
	CORE::pop @{$self->{dirs}}
    }	
    else {
	require Carp;
	Carp::cluck( "Can't go up from ", 
			length $dirs[-1] ? $dirs[-1]: "empty dir"
	);
    }
}

sub push {
    my $self = shift;
    my $file = shift;
    CORE::push @{$self->{dirs}}, $file if length $file;
}
sub split {
    my($self, $path) = @_;
    my($vol, $dir, $file) = $self->splitpath($path, 1);
    $self->{vol} = $vol;
    $self->{dirs} = [ $self->splitdir($dir) ];
    $self->push($file);
}
sub chop {
    my $self = shift;
    my $dirs = $self->{dirs};
    my $file = '';
    while( @$dirs ) {
	last if @$dirs == 1 and not length $dirs->[0];	# path = '/'
	last if length($file = CORE::pop @$dirs);
    }
    $file;    
}    
    
sub follow {
    my $self = shift;
    my $path = $self -> path;
    my $link = readlink $self->path;
    return $self->relative($link) if defined $link;
    require Carp;
    Carp::confess(
	"Can't readlink ", $self->path, 
    	" : ", 
	(-l $self->path ? "but it is" : "not"), 
	"a link"
    );
}
 
sub relative {
    my($self, $path) = @_;
    unless( $self->file_name_is_absolute($path) ) {
	return unless length($self->chop);
	$path = $self->catdir($self->path, $path);
    }
    # what we want to do here is just set $self->{path}
    # to be read by $self->path; but would need to 
    # unset $self->{path} whenever it becomes invalid
    $self->split($path);
    1;
}

sub resolved {
    my $self = shift;
    my $seen = @_ ? shift : {};
    while( -l $self->path ) {
	return if $seen->{$self->canonical}++;
	return unless $self->follow;
    }
    1;
}

sub resolvedir {
    my $self = shift;
    my $seen = @_ ? shift : {};
    my @path;
    while( 1 ) {
	return unless $self->resolved($seen);
	my $last = $self->chop;
	last unless length $last;
	unshift @path, $last;
    }
    $self->add($_) for @path;    
    1;
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

Copyright 2003, 2005 by Robin Barker

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
