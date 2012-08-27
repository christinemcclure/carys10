#!/usr/bin/perl

# Calendar.pm
# $Id: calendar.pm,v 1.10 2005/10/10 02:14:58 ecklesweb Exp $
# a perl module that provides functions necessary to generate
# a calendar.  The only two functions
# in this module that should be called from an including script are 
# days_in_month and month_start.
#
# Written by Jay Eckles, based in part on a calendar program by Brian Stuart.
# Copyright 2004 Jay Eckles
# This file is licensed under the GPL version 2 and is provided without warranty.  
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
# Created 11/4/97
# $Log: calendar.pm,v $
# Revision 1.10  2005/10/10 02:14:58  ecklesweb
# group functionality, added flags in jconfig
#
# Revision 1.9  2005/10/07 19:58:36  ecklesweb
# repeating events support - 3.0 alpha 1
#
# Revision 1.8  2005/05/16 23:32:26  ecklesweb
# commit following reorg of CVS
#
# Revision 1.7  2005/04/19 02:47:56  ecklesweb
# change comments to license specifically under v2 of GPL
#
# Revision 1.6  2005/03/30 23:51:26  ecklesweb
# multilingual enhancements
#
# Revision 1.4  2004/11/27 19:18:16  ecklesweb
# ID and Log tags in index.cgi and calendar.pm
#

package calendar;
require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = qw(days_in_month month_start) ;
@EXPORT_OK = qw($monthstart $days_in_month) ;

# is_leap returns an integer representing a boolean value (1 for true, 0
# for false).  If the year is a leap year, it returns 1, 0 otherwise. 
# Argument to this function is the year.  days_in_months, 
# year_start use this function.

sub is_leap{

   $year = $_[0] ;

# it is a leap year if it is before 1752 and the year is divisible by 4.
   if( $year <= 1752 ){
      $r = $year % 4 ;
      if( $r == 0 ){
         $is_leap = 1 ;
      }
      else{ $is_leap = 0 ; }
   }
# after 1752, any year divisible by 4 except those divisible by 100 but 
# not by 400 are leap years.
   elsif( $year % 400 == 0 ){
      $is_leap = 1 ;
   }
   elsif( $year % 100 == 0 ){
      $is_leap = 0 ;
   }
   else{
      $is_leap = ( $year % 4 == 0 ) ? 1:0 ;
   }
   return $is_leap ;
}

# days_in_month returns an integer between 28 and 31 representing the 
# number of days in the given month.  Arguments to this function are 
# the month and year.

sub days_in_month{

   $month = $_[0] ;
   $year = $_[1] ;

   if( $month == 4 || $month == 6 || $month == 9 || $month == 11 ){
      $days_in_month = 30 ;
   }
   elsif( $month != 2 ){
      $days_in_month = 31 ;
   }
   else{
      if( is_leap( $year ) ){
         $days_in_month = 29 ;
      }
      else{
         $days_in_month = 28 ;
      }
   }
   return $days_in_month ;   
}

# year_start returns an integer between 0 and 6 representing the day of 
# the week that the given year starts on.  Argument to the function 
# is the year.  year_start is only used by month_start.

sub year_start{
 
   $d = 1; $m = 1; $y = $_[0];
   @d = (0,3,2,5,0,3,5,1,4,6,2,4);
   @day = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);
   %day = 
("Sun" => 0, "Mon" => 1, "Tue" => 2, "Wed" => 3, "Thu" => 4, "Fri" => 5, "Sat" => 6 ) ; 

   $y-- if $m < 3;
   $day = $day[($y+int($y/4)-int($y/100)+int($y/400)+$d[$m-1]+$d) % 7];

   return $day{ $day } ;
}

# month_start returns an integer between 0 and 6 representing the day of 
# the week on which the given month starts.  Arguments to the function 
# are the month and year.

sub month_start{

   $d = 1; $m = $_[0]; $y = $_[1];

   @d = (0,3,2,5,0,3,5,1,4,6,2,4);
   @day = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);
   %day = 
("Sun" => 0, "Mon" => 1, "Tue" => 2, "Wed" => 3, "Thu" => 4, "Fri" => 5, "Sat" => 6 ) ; 

   $y-- if $m < 3;
   $day = $day[($y+int($y/4)-int($y/100)+int($y/400)+$d[$m-1]+$d) % 7];

   return $day{ $day } ;
}

#################################################################################
# Name: timeCompare
#
# Description:
# Compares two Event objects based on time.
#
# Arguments
# $a - first event
# $b - second event
#
# Returns:
# 1 if $a > $b
# 0 if $a == $b
# -1 if $a < $b
#
sub timeCompare{
#   print STDERR "in timeCompare.\n" ;
#@apieces = split( /\|/, $a ) ;
#  @bpieces = split( /\|/, $b ) ;
#$aa = $apieces[0] ;
#$bb = $bpieces[0] ;
#   print STDERR "a when: $main::a->{'when'}\n" ;
#   print STDERR "a summary: $main::a->{'summary'}\n" ;
   my $aa = $main::a->{'when'} ;
   my $bb = $main::b->{'when'} ;
#   print STDERR "aa: $aa; bb: $bb\n" ;
#compare a and b only if both a and b are of format 99:99 AM
   if( $aa =~ /^\d\d?:?(\d\d)? [AP]M/ ){
#      print STDERR "comparing.\n" ;
      if( $bb =~ /^\d\d?:?(\d\d)? [AP]M/ ){
         if( $aa =~ /AM/ && $bb =~ /PM/ ){
            $retvalue = -1 ;
         }
         elsif( $aa =~ /PM/ && $bb =~ /AM/ ){
            $retvalue = 1 ;
         }
         else{
#           if( ($a =~ /AM/ && $b =~ /AM/) || ($a =~ /PM/ && $b=~/PM/) ){
            @apieces = split( / /, $aa ) ;
            @bpieces = split( / /, $bb ) ;
   
            $atime = $apieces[0] ; $btime = $bpieces[0] ;
            $aAmPm = $apieces[1] ; $bAmPm = $bpieces[1] ;
   
            if( $atime =~ /:/ ){
               @apieces = split( /:/, $atime ) ;
               $ahour = $apieces[0] ;
               $amin = $apieces[1] ;
            }
            else{
               $ahour = $atime ;
               $amin = "00" ;
            }
            if( $btime =~ /:/ ){
               @bpieces = split( /:/, $btime ) ;
               $bhour = $bpieces[0] ;
               $bmin = $bpieces[1] ;
            }
            else{
               $bhour = $btime ;
               $bmin = "00" ;
            }
   
            if( $ahour eq "12" && $bhour ne "12" ){
               return $retvalue = -1 ;
            }
            elsif( $bhour eq "12" && $ahour ne "12" ){
               return $retvalue = 1 ;
            }
   
            if( $ahour < $bhour ){
               $retvalue = -1 ;
            }
            elsif( $ahour > $bhour ){
               $retvalue = 1 ;
            }
            else{
               if( $amin < $bmin ){
                  $retvalue = -1 ;
               }
               elsif( $amin > $bmin ){
                  $retvalue = 1 ;
               }
               else{
                  $retvalue = 0 ;
               } #end else amin bmin
            } #end else ahour bhour
         }#end AM PM compare 
      }
      else{
         $retvalue = -1 ;
      }
   }
   else{
      if( $bb =~ /^\d\d?:?(\d\d)? [AP]M/ ){
         $retvalue = 1 ;
      }
      else{
         $retvalue = 0 ;
      }
   }
}

##
# Name: calculate_dates
#
# Description:
#   calculate the list of dates for a repeating event given the starting date,
#   the period (daily, weekly, monthly, or yearly), the frequency (every, every
#   other, every third, every fourth), and the duration (for x periods)
#
# Algorithm:
#   Assume period is represented as follows:
#      daily == 1
#      weekly == 7
#      monthly == 30
#      yearly == 365
#   Assume frequency is represented as follows:
#      every == 1 
#      every other == 2
#      every third == 3 
#      every fourth == 4 
#   If period is daily or weekly, determine how many days are between each date:
#      switch( period )
#         case daily:
#            days between = frequency
#         case weekly:
#            days between = 7*frequency
#      loop floor( duration/frequency ) times:
#         add to list last date + days between
#   If period is monthly, determine how many months are between each date (frequency)
#      loop floor( duration/frequency ) times:
#         add to list last date + months between
#   If period is yearly, determine how many years are between each date (frequency)
#      loop floor( duration/frequency ) times:
#         add to list last date + years between
#   Check for non-sensical dates: February 29 on non-leap year, 31st on a month with 30 or fewer days
#      discard the date if it is non-sensical (later ought to ask the user what to do)
#   
# Arguments:
#    date - starting date
#    period - 1, 7, 30, 365 for daily, weekly, monthly, or yearly
#    frequency - 1, 2, 3, 4 for every, every other, every third, and every fourth
#    duration - number of periods to repeat
#
# Returns:
#    List of dates
#
sub calculate_dates{
   my $date = shift ;
   my $period = shift ;
   my $frequency = shift ;
   my $duration = shift ;
} 

##
# Name: add_days
#
# Description:
#   Add x days to a date, resulting in a new date
#
# Algorithm:
#   If x < 31, 
#      add x to date, result mod number of days in next month

sub add_days{
   my $startdate = shift ;
   my $days = shift ;
   
   $newdate = $startdate + $days ;
   if( $newdate > days_in_month( $month ) ){
      $newdate = $newdate % days_in_month( $month ) ;
      $month = $month+1 ;
      if( $month == 13 ){
         $month = 1 ;
         $year = $year + 1 ;
      }
   }
   
   return $newdate ;
}

###Event class
package Event ;

sub new {
   my($class) = shift;

   bless {      
      "date"    => undef,
      "when" => undef,
      "location" => undef,
      "summary" => undef,
      "details" => undef,
      "repeatperiod" => undef,
      "repeatfrequency" => undef,
      "repeatduration" => undef
   }, $class;
}
