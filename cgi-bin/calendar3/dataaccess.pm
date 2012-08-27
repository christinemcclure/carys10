#!/usr/bin/perl

#dataaccess.pm
# $Id: dataaccess.pm,v 1.20 2006/08/15 18:51:39 espergreen Exp $
#a Perl module that provides an abstraction between the data layer and the application layer
#
# last modified 11-15-2004
#
# by Jay Eckles
# Copyright 2004 Jay Eckles
# This file is licensed under the GPL version 2 and is provided without warranty.
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
# $Log: dataaccess.pm,v $
# Revision 1.20  2006/08/15 18:51:39  espergreen
# commented out debug lines
#
# Revision 1.19  2006/08/15 17:52:44  espergreen
# commented out debug lines
#
# Revision 1.18  2006/06/30 18:08:39  espergreen
# Unix shebangs
#
# Revision 1.17  2005/10/10 15:52:16  ecklesweb
# note: windows-style shebangs.  disable groups if only 1 .db besides empty.db.
#
# Revision 1.15  2005/10/10 02:14:58  ecklesweb
# group functionality, added flags in jconfig
#

package dataaccess ;

use utf8 ;
use Cwd ; #needed for getcwd function
use POSIX qw( ceil ) ;

require Exporter ;
require dnfunc ;
require jconfig ;
require jcgi ;
require calendar ;

@ISA = qw( Exporter ) ;
@EXPORT = qw(set_datasource open_database get_events get_single_event add_single_event add_repeating_event delete_single_event delete_repeating_event_series edit_single_event edit_repeating_event_series) ;
@EXPORT_OK = qw($datasource) ;

$datasource ; # a "global" that will hold the name of the data source to use
$datasource_type ; # what type of datasource is it (for future use - currently only flat-file datanet database is supported)
%calendarbase ; # memory-resident version of calendar database

##
# Name: set_datasource
#
# Description:
# set the datasource to use for retrieving calendar information (currently only supports flat-file datanet database)
#
# Arguments:
# 1. name of datasource
#
# Returns:
# Nothing
##
sub set_datasource{
   $datasource = shift() ;
   #&jcgi::debug( "datasource: $datasource\n" ) ;
   if( $datasource eq "" ){
      &jconfig::loadConfig() ;
      $datasource = $jconfig::value{"defaultDb"} ;
      if( $datasource eq "" ){
         $datasource = "calendar.db" ;
      }
   }
#if we're in the addevent directory, prepend "../" to the datasource.
   #getcwd is from Cwd package
   $pwd = getcwd ;
   if( $pwd =~ /addevent/ ){
      $datasource = "../".$datasource ;
   }

#print STDERR "datasource: $datasource\n" ;
}

##
# Name: open_database
#
# Description:
# Open or establish a connection with the database.
# This is not an exported function.
#
# Arguments:
# None
#
# Returns:
# Nothing
##
sub open_database{
#reset
   %dnfunc::database = {} ;
   %calendarbase = {} ;
#if the calendar database exists
   if( -e $datasource ){
#and if it can be successfully opened
      if( ($status = &dnfunc::dn_open( $datasource )) eq "success" ){
#load the calendar database into memory
         %calendarbase = %dnfunc::database ;
      }
#if the calendar database was not successfully opened, create an empty one.
      else{
         #&jcgi::debug( "dnfunc::dn_open returned $status" ) ;
	 &jcgi::return_error( "Couldn't open the specified database file ($datasource)." ) ;
         %calendarbase = {} ;
      }
   }
#if the calandar database did not exists, create an empty database in memory
   else{
      #&jcgi::debug( "specified datasource $datasource does not exist" ) ;
      &jcgi::return_error( "The specified database file ($datasource) doesn't seem to exist." ) ;
      %calendarbase = {} ;
   }
}

##
# Name: get_events
#
# Description:
# Return an array that contains all of the events for the given date.
# Each element of the array is an Event object (defined in calendar.pm)
#
# Arguments:
# date for which to retreive events
#
# Returns:
# Array of events as described above
##
sub get_events{
   my $date = $_[0] ;
   my @events ;
   @events = () ;

#print STDERR $date."\n" ;

#need to open database in case programmer forgot to do it, but
#more importantly to reset memory-resident version of database!
   &open_database() ;

   @daysevents = split( /&/, $calendarbase{ $date."Events" } ) ;
   @times = split( /&/, $calendarbase{ $date."Times" } ) ;
   @locations = split( /&/, $calendarbase{ $date."Location" } ) ;
   @details = split( /&/, $calendarbase{ $date."Expls" } ) ;

   $i = 0 ;
   foreach $summary (@daysevents){
      $event = new Event ;
      $event->{'date'} = $date ;
      $event->{'summary'} = $summary ;
      $event->{'when'} = $times[$i] ;
      $event->{'location'} = $locations[$i] ;
      $event->{'details'} = $details[$i] ;
      push( @events, $event ) ;
      $i++ ;
   }

   return @events ;
}

##
# Name: add_single_event
#
# Description:
# Add an event to the database given an Event object
#
# Arguments:
# Event object
#
# Returns:
# 0 for failure
# 1 for success
##
sub add_single_event{
   my $event = shift() ;
   my @events = () ;
   my $events = "" ;
   my $expls = "" ;
   my $times = "" ;
   my $location = "" ;
   my $recordstring = "" ;
   my $e ;

#print STDERR "adding $event->{'date'} $event->{'summary'}\n" ;

#return error if date or summary are blank
   if( $event->{'date'} eq "" || $event->{'summary'} eq "" ){
      return 0 ;
   }

#get existing events for date
   @events = &get_events( $event->{'date'} ) ;
#$count = @events ;
#print STDERR "number of events is $count\n" ;
   foreach $e (@events){
      if( $e->{'summary'} ne "" ){
         $events .= $e->{'summary'}."&" ;
         $expls .= $e->{'details'}."&" ;
         $times .= $e->{'when'}."&" ;
         $location .= $e->{'location'}."&" ;
      }
   }

#construct a new string that will be the record for the date
   $events .= $event->{'summary'}."&" ;
   $expls .= $event->{'details'}."&" ;
   $times .= $event->{'when'}."&" ;
   $location .= $event->{'location'}."&" ;
   $recordstring = $event->{'date'}."\|".$events."\|".$expls."\|".$times."\|".$location ;

#print STDERR "adding: $event->{'date'}...$recordstring\n" ;
   &dnfunc::dn_add( $event->{'date'}, $recordstring ) ;

}

##
# Name: add_repeating_event
#
# Description:
# Add a repeating event to the database given an Event object
#
# Arguments:
# Event object
#
# Returns:
# 0 for failure
# 1 for success
##
sub add_repeating_event{
   my $event = $_[0] ;
   my @events = () ;
   my $events = "" ;
   my $expls = "" ;
   my $times = "" ;
   my $location = "" ;
   my $recordstring = "" ;
   my @repeatdates = () ;
   my $d ;
   my $e ;

#return error if date or summary are blank
   if( $event->{'date'} eq "" || $event->{'summary'} eq "" ){
      return 0 ;
   }


   @repeatdates = &calculate_dates( $event->{"date"},
                                   $event->{"repeatfrequency"},
                                   $event->{"repeatperiod"},
                                   $event->{"repeatduration"} ) ;

   foreach $d (@repeatdates){
	   $dates .= $d.", " ;
   }
   #&jcgi::debug( "Repeating Dates: $dates" ) ;

   foreach $d (@repeatdates){
      $events = $expls = $times = $location = ""  ;
      #get existing events for date
      @events = &get_events( $d ) ;

      #print STDERR "number of events is $count\n" ;
      foreach $e (@events){
         if( $e->{'summary'} ne "" ){
            $events .= $e->{'summary'}."&" ;
            $expls .= $e->{'details'}."&" ;
            $times .= $e->{'when'}."&" ;
            $location .= $e->{'location'}."&" ;
         }
      }

#construct a new string that will be the record for the date
      $events .= $event->{'summary'}."&" ;
      $expls .= $event->{'details'}."&" ;
      $times .= $event->{'when'}."&" ;
      $location .= $event->{'location'}."&" ;
      $recordstring = $d."\|".$events."\|".$expls."\|".$times."\|".$location ;

#print STDERR "adding: $event->{'date'}...$recordstring\n" ;
      &dnfunc::dn_add( $d, $recordstring ) ;
   }


}


##
# Name: delete_single_event
#
# Description:
# Delete an event from the database given an Event object
#
# Arguments:
# Event object
#
# Returns:
# 0 for failure
# 1 for success
##
sub delete_single_event{
   my $match = 1 ;
   my $event = $_[0] ;
   my @events = () ;
   my $index ;

#print STDERR "deleting $event->{'date'} $event->{'summary'}\n" ;

   @events = &get_events( $event->{'date'} ) ;

#if there's only one event, just delete it
   if( @events == 1 ){
#print STDERR "deleting only event on that day.\n" ;
      my $status = &dnfunc::dn_delete($event->{'date'}) ;
#print STDERR "dn_delete returned $status\n" ;
#@events = &get_events( $event->{'date'} ) ;
#$count = @events ;
#print STDERR "number of events is $count\n" ;
#print STDERR "first remaining event: $events[0]->{'summary'}\n" ;
      return 1 ;
   }

#if there are multiple events, we'll have to reconstruct the dnfunc record string
#for that date and then update the data file with it.

#if the summary entered into the form matches a summary found in the events list, we'll
#delete the parts of events, expls, and times with the same index.
#print STDERR "attempting to match...\n" ;
   for( $i=0; $match == 1 && $i<@events; $i++ ){
      if( $event->{'summary'} eq $events[$i]->{'summary'} ){
#print STDERR "found match...$event->{'summary'}\n" ;
         $match = 0 ;
      }
   }

   my $events = my $expls = my $times = my $location = "" ;

#if the summary match is found, reconstruct the events, times, and expls scalars
#but leave out the index being deleted
   if( $match == 0 ){
#print STDERR "match equal to zero\n" ;
      $index = $i-1 ;
      for( $i=0; $i<@events; $i++ ){
         if( $i != $index ){
            $events .= $events[$i]->{'summary'}."&" ;
            $expls .= $events[$i]->{'details'}."&" ;
            $times .= $events[$i]->{'when'}."&" ;
            $location .= $events[$i]->{'location'}."&" ;
         }
      }
#construct the new string that will be the record
      my $recordstring = $event->{'date'}."\|".$events."\|".$expls."\|".$times."\|".$location ;
#print STDERR "new recordstring: $recordstring\n" ;
#add the newly constructed record string to the database
      &dnfunc::dn_add( $event->{'date'}, $recordstring ) ;
      return 1 ;
   }
   else{
      return 0 ;
   }
}

##
# Name: update_single_event
#
# Description:
# Update an event in the database given two Event objects,
# one representing the event to be updated, the other the
# new event with the new details that should be updated.
# This will be achieved by deleting the first event, then
# adding the new event.
#
# Arguments:
# "Old" Event object that is being updated
# "New" Event object that contains updated information
#
# Returns:
# 0 for failure
# 1 for success
##
sub update_single_event(){
#print STDERR "deleting event $_[0]->{'date'} $_[0]->{'summary'}\n" ;
   my $oldevent = $_[0] ;
   my $newevent = $_[1] ;
   &delete_single_event( $oldevent ) ;
   &add_single_event( $newevent ) ;
}

##
# Name: calculate_dates
#
# Description:
# Calculate the list of actual dates to which a repeating event needs to be added
# (or in the future updated/deleted?)
#
# Arguments:
# date - date for parent event
# frequency - 1 for every
#             2 for every other
#             3 for every third
#             4 for every fourth
# period    - 1 for day
#             2 for week
#             3 for month
#             4 for year
# duration - arbitrary number, how many dates to calculate
#
# Returns:
# 0 for failure
# 1 for success
##
sub calculate_dates(){
#print STDERR "deleting event $_[0]->{'date'} $_[0]->{'summary'}\n" ;
   my $date = shift() ;
   my $frequency = shift() ;
   my $period = shift() ;
   my $duration = shift() ;

   #print STDERR "date: $date; frequency: $frequency; period: $period; duration: $duration\n" ;

   if( $period == 1 ){
	   return &calculate_daily_dates( $date, $frequency, $duration ) ;
   }
   if( $period == 7 ){
	   return &calculate_weekly_dates( $date, $frequency, $duration ) ;
   }
   if( $period == 30 ){
	   return &calculate_monthly_dates( $date, $frequency, $duration ) ;
   }
   if( $period == 365 ){
	   return &calculate_yearly_dates( $date, $frequency, $duration ) ;
   }
}

sub calculate_daily_dates(){
	my $date = shift() ;
	my $frequency = shift() ;
	my $duration = shift() ;
	my @dates ;

	$numberOfDates = ceil( $duration/$frequency ) ;

	for( $i=0; $i<$numberOfDates; $i++ ){
		push( @dates, $date ) ;
		$newdate = &addDays( $date, $frequency ) ;
		$date = $newdate ;
	}

	return @dates ;
}

sub calculate_weekly_dates(){
	my $date = shift() ;
	my $frequency = shift() ;
	my $duration = shift() ;
	my @dates ;

	$numberOfDates = ceil( $duration/$frequency ) ;

	for( $i=0; $i<$numberOfDates; $i++ ){
		push( @dates, $date ) ;
		$newdate = &addDays( $date, $frequency*7 ) ;
		$date = $newdate ;
	}

	return @dates ;
}

sub addDays(){
	my $date = shift() ;
	my $addDays = shift() ;

	($day,$month,$year) = split( /-/, $date ) ;

	#&jcgi::debug( "days: start: $newday" ) ;
	$newday = $day + $addDays ;
	#&jcgi::debug( "days: sum: $newday" ) ;
	while( $newday > ($dim = &calendar::days_in_month( $month, $year )) ){
	#&jcgi::debug( "days: dim: $dim" ) ;
		$newday = $newday - $dim ;
	#&jcgi::debug( "days: diff: $newday" ) ;
		$month++ ;
	#&jcgi::debug( "days: month: $month" ) ;
		if( $month > 12 ){
			$month = 1 ;
			$year++ ;
		}
	}
	#&jcgi::debug( "days: finish: $newday" ) ;
	return $newday."-".$month."-".$year ;

}

sub calculate_monthly_dates(){
	my $date = shift() ;
	my $frequency = shift() ;
	my $duration = shift() ;
	my @dates ;

	$numberOfDates = ceil( $duration/$frequency ) ;

	for( $i=0; $i<$numberOfDates; $i++ ){
		push( @dates, $date ) ;
		$newdate = &addMonths( $date, $frequency ) ;
		$date = $newdate ;
	}

	return @dates ;
}

sub addMonths(){
	my $date = shift() ;
	my $number = shift() ;

	($day,$month,$year) = split( /-/, $date ) ;
	$newmonth = $month + $number ;
	while( $newmonth > 12 ){
	   $year++ ;
           $newmonth -= 12 ;
   	}
	return $day."-".$newmonth."-".$year
}

sub calculate_yearly_dates(){
	my $date = shift() ;
	my $frequency = shift() ;
	my $duration = shift() ;
	my @dates ;

	($day,$month,$year) = split( /-/, $date ) ;

	for( $i=0; $i<int($duration/$frequency); $i++ ){
		push( @dates, $day."-".$month."-".$year ) ;
		$year = $year + $frequency ;
	}
	return @dates ;
}

sub listGroups(){
	my @groups ;
	my @grouplist ;

	#get list of .db files from current directory
	@groups = glob("./*.db");

	#strip the ".db" off the end of each file name
	foreach $group (@groups){
		#ignore empty.db
		if( $group !~ /empty\.db/ ){
			#strip .db off the end
			$group =~ s/\.db$//g ;
			#strip ./ off the beginning
			$group =~ s/^\.\///g ;
			push( @grouplist, $group ) ;
		}
	}
	#return the stripped names
	if( @grouplist <= 1 ){
		$jconfig::value{'enableGroups'} = "false" ;
	}
	return @grouplist ;
}

1 ;
