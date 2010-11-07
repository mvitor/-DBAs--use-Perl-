#!/usr/bin/perl
use strict;
use warnings;
use DBI;

# Connect to the database
my $dbh=DBI->connect("dbi:Oracle(PrintError=>1):ORCL",'hr','Nsys201') or die "Error connecting on database %sid";
# We prepare once, Oracle makes hard parse once
my $sth = $dbh->prepare('INSERT INTO regions (region_id, region_name) VALUES (:REGION_ID,:REGION_NAME)');

# Data to be loaded in hash format
my %regions = ( '20' => 'South America',
				'30' => 'Arctic',
				'40' => 'Mediterranean',
			  );

# Loop through the data inserting one by one but using the same execution plan calculated for the first statement
foreach my $region_id  (keys %regions){

	$sth->bind_param(':REGION_ID',$region_id);
	$sth->bind_param(':REGION_NAME',$regions{$region_id});
	$sth->execute();
}
# Finish statatement opened then disconnect from the database

$sth->finish;
$dbh->disconnect;

