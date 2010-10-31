#!/usr/nin/perl/
use strict;
use warnings;
use DBI;
use File::Copy;
use DateTime;

# Im running a 10g so i set the variable $PARAM_DIAGNOSTIC_DEST  to 'background_dump', if you are on 11g set it to 'diagnostic_dest'
my $PARAM_DIAGNOSTIC_DEST = 'background_dump_dest';
# Path where the old alert logs will be saved - Be sure that the path is created
my $BACKUPLOG_DIR = '/backup_folder/';
# Max size in megabytes
my $MAXLOGSIZE_THRESHOLD = '2';

my @SIDS = qw/ODWP OSWP OEWP OWWP/;

for my $sid (@SIDS)	{
	# Connect, query the parameter then disconnect from the database
	my $dbh=DBI->connect("dbi:Oracle(PrintError=>1):$sid",'system','wanted16') or die "Error connecting on database %sid";
	my $sth = $dbh->prepare('select value from v$parameter where name=?');
	$sth->execute($PARAM_DIAGNOSTIC_DEST);
	my $alertlog_dir = $sth->fetchrow_arrayref->[0];
	$sth->finish;
	$dbh->disconnect;
	# Check if dir was found and if dir and alert log file exist
	unless ($alertlog_dir)	{
		die "Parameter $PARAM_DIAGNOSTIC_DEST not found on database $sid\n";
	}
	print "Parameter $PARAM_DIAGNOSTIC_DEST found on database $sid: $alertlog_dir\n";
	my $alertlog_file ; #mvitor
	unless (-f $alertlog_dir)	{
		$alertlog_file  = 'alertlogfile.txt';
		die "Alert Log dir doesn't exist: $alertlog_dir for database $sid";
	}
	my $alertlog_file = $alertlog_dir.'alert_'.$sid.'.log';
	unless (-f $alertlog_file)	{
		$alertlog_file  = 'alertlogfile.txt';
		die "Alert Log file doesn't exist: $alertlog_file for database $sid";
	}
	# Get alert log size and convert it to MB
	my $alertlog_size = (-s $alertlog_file)/1024/1024;
	# Compare it to threshold set
	if ($alertlog_size >= $MAXLOGSIZE_THRESHOLD)	{
		print "Alert log for $sid excedeed threshold, moving alert log file $alertlog_file to $BACKUPLOG_DIR\n";
		# We use DateTime module to get current date
		my $dt = DateTime->now;
		my $new_alert_log = 'alert_'.$dt->mdy.'-'.$dt->hms('-').$sid.'.log';
		# Move the file to new location with a new name
		move($alertlog_file, $BACKUPLOG_DIR.'/'.$new_alert_log) or die "Error moving alertlog file $! for database $sid";
		print "Alert log file $alertlog_file moved successfully to ".$BACKUPLOG_DIR.'/'.$new_alert_log."\n";
	}
	else	{
		print "Skipping moving for DB $sid: Alert log file is Ok\n";
	}
}

