package Apache::CGI;
require Apache;
#require Apache::TieHandle;
#CGI->require_version(2.22);
use vars qw(@ISA $VERSION);

eval {require CGI::XA;};
if ($@) {
    $CGI::DefaultClass = 'CGI';
    require CGI;
    @ISA = qw(CGI); # maybe 
} else {
    @ISA = qw(CGI::XA);
}

$VERSION = "0.11301-alpha";

sub new {
    my($class) = shift;
    #tie *STDOUT => 'Apache::TieHandle';
    %ENV = Apache->request->cgi_env;
    my $self = $class->SUPER::new(@_);
    $self->{'.req'} = Apache->request;
    $self;
}

sub header {
    my $self = shift;
    my $r = $self->{'.req'};
    $r->basic_http_header;
    return $self->CGI::XA::header(@hdrs);
}		     

sub print {
    my($self) = shift;
    $self->{'.req'}->write_client(@_);
}

sub read_from_client {
    my($self, $fh, $buff, $len, $offset) = @_;
    my $r = $self->{'.req'} || Apache->request;
    my($own_buffer,$ret);
    # A.K.: unfortunately I couldn't find a way without our own buffer
    $ret = $r->read_client_block($own_buffer, $len);
#    my $own_len = length($own_buffer);
    if ($offset) {
	substr($$buff,$offset) = substr($own_buffer,0,$ret);
    } else {
	$$buff = substr($own_buffer,0,$ret);
    }
#    my $fulllen = length($$buff);
#    my $caller = "";#Carp::longmess();
#    warn qq{ret [$ret] len [$len] offset [$offset] own_len [$own_len] fulllen [$fulllen] caller [$caller]\n};
#    my $obs = substr($own_buffer,0,15);
#    my $obe = substr($own_buffer,-15);
#    warn qq{own_buffer [$obs]...[$obe] his buff [$$buff]\n};
    $ret;
}

sub new_MultipartBuffer {
    my $self = shift;
    my $new = Apache::MultipartBuffer->new($self, @_); 
    $new->{'.req'} = $self->{'.req'} || Apache->request;
    return $new;
}

package Apache::MultipartBuffer;
@ISA = qw(CGI::XA::MultipartBuffer);

sub wouldBlock { undef }
*Apache::MultipartBuffer::read_from_client = \&Apache::CGI::read_from_client;

1;

__END__

=head1 NAME

Apache::CGI - Make things work with CGI.pm against Perl-Apache API

=head1 SYNOPSIS

 
 require Apache::CGI;

 my $q = new Apache::CGI;

 $q->print($q->header);

 #do things just like you do with CGI.pm

=head1 DESCRIPTION

When using the Perl-Apache API, your applications are faster, but the
enviroment is different than CGI.
This module attempts to set-up that environment as best it can.

=head1 SEE ALSO

perl(1), Apache(3), CGI(3)

=head1 AUTHOR

Doug MacEachern E<lt>dougm@osf.orgE<gt>, hacked over by Andreas König E<lt>a.koenig@mind.deE<gt>

=cut
