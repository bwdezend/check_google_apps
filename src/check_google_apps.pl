#!/usr/bin/env perl

# version 1.1 (2013-04-23)
#   bwdezend

use JSON::PP;
use strict;
use Getopt::Long;

my $warnings    = 0;
my @problems    = undef;
my $serviceName = undef;
my $serviceID   = undef;
my $status      = 'OK';
my $value       = undef;

GetOptions( "service=s" => \$serviceName );

my $content = `curl http://www.google.com/appsstatus/json/en 2>/dev/null`;
$content =~ s/dashboard.jsonp\(//g;
$content =~ s/\)\;$//g;
my $parser       = new JSON::PP;
my $jsonResponse = $parser->allow_nonref->max_depth(2048)->decode($content);
my %services;
foreach my $entry ( @{ $jsonResponse->{services} } ) {
    $services{ $entry->{id} } = $entry->{name};
}

while ( my ( $k, $v ) = each %services ) {
    if ( $serviceName eq $v ) { $serviceID = $k }
}

unless ( defined $serviceName ) {
    $status = "UNKNOWN";
    &exit_with_status("No App Specified");
}

unless ( defined $serviceID ) {
    print "Available Google Applications:\n";

    while ( my ( $k, $v ) = each %services ) {
        print "  $v\n";
    }

    $status = "UNKNOWN";
    &exit_with_status("Invalid App ($serviceName) Specified");
}

foreach my $entry ( @{ $jsonResponse->{messages} } ) {
    unless ( $entry->{resolved} eq '1' ) {
        if ( $entry->{service} eq $serviceID ) {
            push( @problems, "$services{$entry->{service}}" );
            $warnings++;
            $status = 'WARNING';
        }
    }
}

if ( $warnings ne '0' ) {
    &exit_with_status(
"$serviceName is having problems - please see http://www.google.com/appsstatus for more details"
    );
}
if ( $warnings eq '0' ) {
    &exit_with_status("$serviceName is operating normally");
}

exit;

sub exit_with_status {

    #print out the single line of nagios command output, with perfdata
    if ( $status eq 'UNKNOWN' ) { print "$status - $_[0]\n"; exit 3 }
    print "$status - $_[0] $value | warnings=$warnings\n";
    if ( $status eq 'CRITICAL' ) { exit 2 }
    if ( $status eq 'WARNING' )  { exit 1 }
    if ( $status eq 'OK' )       { exit 0 }
}

