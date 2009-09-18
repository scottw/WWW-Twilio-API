package WWW::Twilio::API;

use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';
our $Debug   = 0;

use Crypt::SSLeay ();
use LWP::UserAgent ();
use URI::Escape 'uri_escape';
use Carp 'croak';

sub API_URL     { 'https://api.twilio.com' }
sub API_VERSION { '2008-08-01' }

## NOTE: This is an inside-out object; remove members in
## NOTE: the DESTROY() sub if you add additional members.

my %errors      = ();
my %account_sid = ();
my %auth_token  = ();

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = bless \(my $ref), $class;

    $errors      {$self} = [ ];
    $account_sid {$self} = $args{AccountSid} || '';
    $auth_token  {$self} = $args{AuthToken}  || '';

    return $self;
}

sub GET {
    _do_request(shift, METHOD => 'GET', API => shift, @_);
}

sub POST {
    _do_request(shift, METHOD => 'POST', API => shift, @_);
}

sub PUT {
    _do_request(shift, METHOD => 'PUT', API => shift, @_);
}

sub DELETE {
    _do_request(shift, METHOD => 'DELETE', API => shift, @_);
}

## METHOD => GET|POST|PUT|DELETE
## API    => Calls|Accounts|OutgoingCallerIds|IncomingPhoneNumbers|
##           Recordings|Notifications|etc.
sub _do_request {
    my $self = shift;
    my %args = @_;

    my $lwp = LWP::UserAgent->new;
    $lwp->agent("perl-WWW-Twilio-API/$VERSION");

    my $method = delete $args{METHOD};

    my $url = API_URL() . '/' . API_VERSION();
    my $api = delete $args{API};
    $url .= "/Accounts/" . $account_sid{$self};
    $url .= ( $api eq 'Accounts' ? '' : "/$api" );

    my $req = HTTP::Request->new( $method => $url );
    $req->authorization_basic( $account_sid{$self}, $auth_token{$self} );
    if( keys %args ) {
        $req->content_type( 'application/x-www-form-urlencoded' );
        $req->content( _build_content( %args ) );
    }

    local $ENV{HTTPS_DEBUG} = $Debug;
    my $res = $lwp->request($req);

    unless( $res->code =~ /^2\d\d$/ ) {
        $self->errors("Failure: " . $res->code . ': ' . $res->message);
        return;
    }

    return { xml => $res->content };
}

## builds a string suitable for LWP's content() method
sub _build_content {
    my %args = @_;

    my @args = ();
    for my $key ( keys %args ) {
        $args{$key} = ( defined $args{$key} ? $args{$key} : '' );
        push @args, uri_escape($key) . '=' . uri_escape($args{$key});
    }

    return join('&', @args) || '';
}

sub send {
    shift->_do_request(@_);
}

sub errors {
    my $self = shift;

    if( @_ ) {
        push @{ $errors{$self} }, @_;
        return;
    }

    return @{ $errors{$self} };
}

sub clear_errors {
    my $self = shift;
    $errors{$self} = [];
}

sub DESTROY {
    my $self = $_[0];

    delete $errors      {$self};
    delete $account_sid {$self};
    delete $auth_token  {$self};

    my $super = $self->can("SUPER::DESTROY");
    goto &$super if $super;
}

1;
__END__

=head1 NAME

WWW::Twilio::API - Perl extension for accessing Twilio's REST API

=head1 SYNOPSIS

  use WWW::Twilio::API;

  my $twilio = WWW::Twilio::API->new(AccountSid => 'AC712345...',
                                     AuthToken  => '12345678...');

  $response = $twilio->POST( Calls, %args );
  print $response->{xml};


=head1 DESCRIPTION



=head1 SEE ALSO

LWP(1)

=head1 AUTHOR

Scott Wiersdorf, E<lt>scott@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Scott Wiersdorf

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
