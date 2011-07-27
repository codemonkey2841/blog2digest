#!/usr/bin/perl

#############################
#
# Filename:        code_review.pl
# Project:         code_review
# Number of Files: 1
# Language:        Perl
# Platform:        Linux
# Summary:         This script creates a digest email out of blog entries
#                  made over the last week.
#
#############################
use strict;

use Config::Simple;
use Data::Dumper;
use LWP::Simple;
use Time::Local;
use XML::Simple;

# Extract the directory where the script lives
$0 =~ /^(.*)code_review.pl$/;
my $dir = $1;

# Retrieve variables from the config file
Config::Simple->import_from($dir . 'code_review.ini', \%config);
my $feed = $config{'default.feed_url'};
my $from = $config{'default.from_email'};
my $to   = $config{'default.to_email'};

# Gather entries from the Feed URL into an XML entity
my $xml = new XML::Simple;
my $blob = get( $feed );
my $content = $xml->XMLin( $blob );
my $entries = $content->{entry};

# Timestamp for precisely 7 days earlier
my $lastweek = time - 604800;
# A hash to hold all relevant entries
my %things;

foreach my $entry (sort keys %$entries) {
   # Turn the formatted publish time of the entry and convert it to
   #  a Unix timestamp
   my $time = $entries->{$entry}->{published};
   $time =~ /(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)/;
   $time = timegm($6, $5, $4, $3, $2-1, $1);

   # If the publish timestamp is within a week then store the entry
   if( $time > $lastweek ) {
      $things{$time} = $entries->{$entry}->{content}->{content} . "\n";
   }
}

# Create formatted lines to pass to sendmail
my $sendmail = "/usr/sbin/sendmail -t";
my $reply_to = "Reply-to: $from\n";
my $subject  = "Subject: Weekly Code Review Update\n";
my $send_to  = "To: $to\n";

# Use sendmail to email the entries to the appropriate address
open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
print SENDMAIL $reply_to;
print SENDMAIL $subject;
print SENDMAIL $send_to;
print SENDMAIL "Content-type: text/html\n\n";

foreach my $entry (sort keys %things) {
   print SENDMAIL "<b>" . localtime($entry) . "</b><br>\n";
   print SENDMAIL $things{$entry} . "<br><br>\n";
}

close(SENDMAIL);
