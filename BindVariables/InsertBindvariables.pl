#!/usr/bin/perl
use strict;
use warnings;
use DBI;

# Connect to the database
my $dbh=DBI->connect("dbi:Oracle(PrintError=>1):ORCL",'hr','utsys201') or die "Error connecting on database %sid";

# We prepare once, Oracle makes hard parse once
my $sth = $dbh->prepare('INSERT INTO regions (region_id, region_name) VALUES (?, ?)');

# Data to be loaded in hash format
my %regions = ( '20' => 'Middle East',
				'30' => 'Arctic',
				'40' => 'Mediterranean',
			  );

# Loop through the data inserting one by one but using the same execution plan calculated for the first statement
foreach my $region_id  (keys %regions){
	$sth->execute($region_id,$regions{$region_id});
}
# Finish statatement opened then disconnect from the database
$sth->finish;
$dbh->disconnect;

