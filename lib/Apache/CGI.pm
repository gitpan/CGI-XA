package Apache::CGI;
require Apache;
#require Apache::TieHandle;

BEGIN { $CGI::XA::DefaultClass = 'Apache::CGI'; };
require CGI::XA;
#CGI->require_version(2.22);
use vars qw(@ISA $VERSION);
@ISA = qw(CGI::XA);

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
    my $own_buffer;
    my $ret = $r->read_client_block($own_buffer, $len);
    # the return value is not correct in any case! I take the length instead as return value
    $offset ? (substr($$buff,$offset) = $own_buffer) : ($$buff = $own_buffer);
    my $own_len = length($own_buffer);
#    my $fulllen = length($$buff);
#    my $caller = "";#Carp::longmess();
#    warn qq{ret [$ret] len [$len] offset [$offset] own_len [$own_len] fulllen [$fulllen] caller [$caller]\n};
    $own_len;
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

Doug MacEachern <dougm@osf.org>

=cut
