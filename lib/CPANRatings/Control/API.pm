package CPANRatings::Control::API;
use strict;
use base qw(CPANRatings::Control Combust::Control::API);
use Combust::Constant qw(OK NOT_FOUND);
use Sys::Hostname qw(hostname);
use CPANRatings::API;
use Return::Value;

sub check_auth {
    my $self = shift;
    my $method = shift;

    # allow anyone to fetch the unhelpful reviews via API
    return success if $method eq 'review/get';

    return failure 'Invalid Auth Token'
      unless (($self->req_param('auth_token') || '')
              eq $self->user_auth_token($self->cookie('uq')));
}


1;

