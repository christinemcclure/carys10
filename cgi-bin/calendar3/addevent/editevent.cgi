#!/usr/bin/perl
#
#calendar database should be in form
#Day|Events|Expls|Times|Location

push( @INC, ".." ) ;

use utf8 ;

require jcgi;
require jconfig ;
require dataaccess ;
require calendar ;
require language ;

&jconfig::loadConfig() ;

$cgiurl = $jconfig::value{"cgiUrl"} ;

#############################################################################
#Editevent.cgi
# $Id: editevent.cgi,v 1.19 2007/03/12 23:39:43 espergreen Exp $
# Copyright 2004 Jay Eckles
#    CSS class names used in HTML Copyright Isaac McGowan, used under GPL.
# This file is licensed under the GPL version 2 and is provided without warranty.
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
# This cgi script is used as a part of the CGI Calendar system, a collection
# of perl scripts and modules with the purpose of creating a web-based
# group event calendar.
#
# This script's job is to 1. edit an event in the calendar database
#                         2. generate an html form for editing an event
# Which event should be edited is communicated to the script via
# an html form.  The following is a list of the name and value pairs that
# Addevent.cgi must receive and the order in which they must be received.
# If a name/value pair is optional, it is listed in square brackets ([]).
# if multiple values are possible for a name, all optional values are
# listed in parentheses (()), and spearated by pipes (|)
#
# mode=(add|delete|gen)
# month=an integer greater than or equal to 1 and less than or equal to 12
# date=an integer greater than or equal to 1 and less than or equal to 31
# year=a positive integer
# [time=a string in the format hh:mm where hh is a one or two digit integer
#      greater than or equal to 1 and less than or equal to 12, and mm is
#      a two digit integer greater than or equal to 0 and less than or
#      equal to 59]
# [ampm=(AM|PM)]
# summary=a string containing no newline characters
# [extended=a string containing no newline characters]
# [location]
#
# These name/value pairs may be passed to the cgi program using either the
# GET or POST methods.  The information is retrieved by calling a function
# found in the cgi.pm module.
#
# The addition or deletion of the information from the database is accomplished
# by retrieving the current record for the date indicated, altering that record,
# then updating that record in the database by using the add function
# provided by the dnfunc.pm module.
#
# One line must be changed in this script to set it up for a new server; that
# is line 9.  It must be changed from
# $cgiurl = "http://127.0.0.1/cgi-bin/calendar2/index.cgi" ;
# to
# $cgiurl = "http://newserverdomain/pathtocalendardir/index.cgi" ;
# where newserverdomain is the domain of the new server the calendar is being
# setup on and pathtocalendardir is the path to the calendar directory
# containing index.cgi.
#
# $Log: editevent.cgi,v $
# Revision 1.19  2007/03/12 23:39:43  espergreen
# details is populated on the edit screen
#
# Revision 1.18  2007/03/10 00:15:19  espergreen
# AM/PM is populated on the edit screen
#
# Revision 1.17  2006/08/15 18:45:19  espergreen
# html is now valid
#
# Revision 1.16  2006/08/15 17:54:04  espergreen
# commented out debug lines
#
# Revision 1.15  2006/06/30 18:08:39  espergreen
# Unix shebangs
#
# Revision 1.14  2005/10/10 15:45:01  ecklesweb
# note - contains windows-style shebangs.  finalization of group dropdown.
#
# Revision 1.13  2005/09/15 17:01:50  ecklesweb
# bug fix in editevent, updated readme and faq
#
# Revision 1.12  2005/09/15 15:09:41  ecklesweb
# bug fix for multiple calendar databases
#
################################################################################

#retrieve the name/value pairs via a function made available by cgi.pm
@input = &jcgi::retrieve_input() ;

#load text
$lang = $jcgi::in{"lang"} ;
if( $lang eq "" ){
   $lang = $jconfig::value{"defaultLanguage"} ;
}
if( $lang eq "" ){
   $lang = "en-us" ;
}
&language::loadText( $lang ) ;

&dataaccess::set_datasource( $jcgi::in{"db"} ) ;
$dbname = $jcgi::in{"db"} ;

&dataaccess::open_database() ;

$mode = $jcgi::in{"mode"} ;

$month = $jcgi::in{"month"} ;

$date = $jcgi::in{"date"} ;

$year = $jcgi::in{"year"} ;

$newmonth = $jcgi::in{"newmonth"} ;

$newdate = $jcgi::in{"newdate"} ;

$newyear = $jcgi::in{"newyear"} ;


#create a key based on the date given...key is in format dd-mm-yyyy
$key = $date."-".$month."-".$year ;

@day_record = &dataaccess::get_events( $key ) ;

#split the record up
$events = $day_record[1] ;
$expls = $day_record[2] ;
$times = $day_record[3] ;
$location = $day_record[4] ;
#split up the events, expls, and times, into separate pieces
foreach $record (@day_record){
   push( @events, $record->{'summary'} ) ;
   push( @expls, $record->{'details'} ) ;
   push( @times, $record->{'when'} ) ;
   push( @location, $record->{'location'} ) ;
}

   $time = $jcgi::in{"time"} ;

   $ampm = $jcgi::in{"ampm"} ;

   $summary = $jcgi::in{"summary"} ;
   $newsummary = $jcgi::in{"newsummary"} ;

   $extended = $jcgi::in{"extended"} ;

   $locat = $jcgi::in{"location"} ;

$match = 0 ;
$editMe = 9999999 ;
for( $i = 0; $i < @events; $i++ ){
   if( $events[$i] eq $summary ){
      $editMe = $i ;
	   $match = 1 ;
      #print STDERR "match: $events[$i]\n" ;
	   last ;
   }
}


if( $mode eq "edit" ){

#######################################Edit Mode##########################################

   if( $summary eq "" || $newmonth eq "" || $newdate eq "" || $newyear eq "" ){
      &jcgi::return_error( "You must enter the month, date, year, and a summary for the event!<br>month: $newmonth date: $newdate year: $newyear summary: $summary" ) ;
   }


#if the summary match is found, reconstruct the events, times, and expls scalars
#but leave out the index being deleted
   if( $match == 1 ){
      $newkey =  $newdate."-".$newmonth."-".$newyear ;

      $newevent = new Event ;
      $newevent->{'summary'} = $newsummary ;
      $newevent->{'date'} = $newkey ;
      $newevent->{'when'} = $time." ".$ampm ;
      $newevent->{'details'} = &jcgi::encode( $extended ) ;
      $newevent->{'location'} = &jcgi::encode( $locat ) ;

      &dataaccess::update_single_event( $day_record[$editMe], $newevent ) ;

#finally, send the user back the the calendar, loading the month and year that he
#added an event to.
      &jcgi::print_header( "Location", "$cgiurl?lang=$lang&db=$dbname&month=$month&year=$year" ) ;
   }#end if($match)

#if the match was not found, return a message saying the deletion failed and die.
   else{
      &jcgi::return_error( "The summary you entered in the form did not match any event summary for this date in the database." ) ;
   }
}

elsif( $mode eq "gen" ){
##################################Gen Mode###################################

   open( HTML, "editevent.html" ) ;

   $line = 0 ;
   $monthname = $language::monthnames[$month-1] ;
	     $ampmonly = $times[$editMe] ;
		 if( $ampmonly =~ / AM/ || $ampmonly =~ /AM/  ){
		    $ampmonly = "AM" ;
		 }
		 elsif( $ampmonly =~ / PM/ ){
		    $ampmonly = "PM" ;
		 }
		 else{
		    $ampmonly = "" ;
       }
   while( $input = <HTML> ){
      if( $input =~ /^<input type=hidden name=db>/ ){
         $html[$line] = "<input type=hidden name=db value='$dbname'>\n" ;
      }
      elsif( $input =~ /^<input type=hidden name=lang>/ ){
         $html[$line] = "<input type=hidden name=lang value='$lang'>\n" ;
      }
      elsif( $input =~ /^<input type=hidden name=month>/ ){
         $html[$line] = "<input type=hidden name=month value='$month'>\n" ;
      }
      elsif( $input =~ /^<input type=hidden name=date>/ ){
         $html[$line] = "<input type=hidden name=date value='$date'>\n" ;
      }
      elsif( $input =~ /^<input type=hidden name=year>/ ){
         $html[$line] = "<input type=hidden name=year value='$year'>\n" ;
      }
      elsif( $input =~ /^<input type=text size=2 name=newdate>/ ){
         $html[$line] = "<input type=text size=2 name=newdate value='$date'>\n" ;
      }
      elsif( $input =~ /^<input type=text size=4 name=newyear>/ ){
         $html[$line] = "<input type=text size=4 name=newyear value='$year'>\n" ;
      }
      elsif( $input =~ /^<input type=hidden name=summary>/ ){
         $html[$line] = "<input type=hidden name=summary value=\"$summary\">\n" ;
      }
      elsif( $input =~ /^<input type=text size=20 name=newsummary>/ ){
         $html[$line] = "<input type=text size=20 name=newsummary value=\"$summary\">\n" ;
      }
      elsif( $input =~ /^<input type=text size=5 name=time>/ ){
         $timeonly = $times[$editMe] ;
         $timeonly =~ s/ AM//g ;
            $timeonly =~ s/ PM//g ;
            $timeonly =~ s/^ //g ;
            $timeonly =~ s/ $//g ;

            $html[$line] = "<input type=text size=5 name=time value=\"$timeonly\">\n" ;
      }
      elsif( $input =~ /^<option value=$ampmonly>/ ){
         $html[$line] = "<option value='$ampmonly' selected>\n" ;
      }
      elsif( $input =~ /^<input type=text size=20 name=location>/ ){
         @decodedLocation = &jcgi::decode($location[$editMe] );
         @decodedLocation = &jcgi::decode($decodedLocation[0] ) ;
#$decodedLocation =~ s/\<*\>//g ;
         $html[$line] = "<input type=text size=20 name=location value=\"$decodedLocation[0]\">\n" ;
      }
      elsif( $input =~ /^<textarea cols=50 rows=3 name=extended><\/textarea>/ ){
         @decodedExpl = &jcgi::decode($expls[$editMe] );
         @decodedExpl = &jcgi::decode($decodedExpl[0] ) ;
         $html[$line] = "<textarea cols=50 rows=3 name=extended>$decodedExpl[0]<\/textarea>\n" ;
      }
      elsif( $input =~ /^<!--edittitle-->/ ){
         $html[$line] = $language::edittitle."\n" ;
      }
      elsif( $input =~ /^<!--formdate-->/ ){
         $html[$line] = $language::formdate."\n" ;
      }
      elsif( $input =~ /^<!--formwhat-->/ ){
         $html[$line] = $language::formwhat."\n" ;
      }
      elsif( $input =~ /^<!--formwhen-->/ ){
         $html[$line] = $language::formwhen."\n" ;
      }
      elsif( $input =~ /^<!--formwhere-->/ ){
         $html[$line] = $language::formwhere."\n" ;
      }
      elsif( $input =~ /^<!--formdetails-->/ ){
         $html[$line] = $language::formdetails."\n" ;
      }
      elsif( $input =~ /^<!--am-->/ ){
         $html[$line] = $language::am."\n" ;
      }
      elsif( $input =~ /^<!--pm-->/ ){
         $html[$line] = $language::pm."\n" ;
      }
      elsif( $input =~ /^<!--editvalue-->/ ){
         $html[$line] = "\"".$language::editvalue."\""."\n" ;
      }
      elsif( $input =~ /^<!--cancelvalue-->/ ){
         $html[$line] = "\"".$language::cancelvalue."\""."\n" ;
      }
      elsif( $input =~ /^<!--monthlist-->/ ){
         for( $i=1; $i<=12; $i++ ){
            if( $month == $i ){
               $html[$line] = "<option value='$i' selected>$language::monthnames[$i-1]\n" ;
            }
            else{
               $html[$line] = "<option value='$i'>$language::monthnames[$i-1]\n" ;
            }
            $line++ ;
         }
      }
      elsif( $input =~ /^<input type=text size=2 name=date>/ ){
         $html[$line] = "<input type=text size=2 name=date value='$date'>\n" ;
      }
      elsif( $input =~ /^<input type=text size=4 name=year>/ ){
         $html[$line] = "<input type=text size=4 name=year value='$year'>\n" ;
      }
      else{
         $html[$line] = $input ;
      }
      $line++ ;
   }
   close( HTML ) ;

   open( TOP, "../top.html" ) ;
   $i = 0 ;
   while( $input = <TOP> ){
      if( $input =~ /<LINK REL=stylesheet TYPE=text\/css HREF=\/calendar.css>/ ){
	     if( $jconfig::value{"cssUrl"} ne "" ){
			$input = "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"".$jconfig::value{"cssUrl"}."\">" ;
		 }
	  }
      $top[$i] = $input ;
      $i++ ;
   }
   close( TOP ) ;
   open( BOT, "../bot.html" ) ;
   $i = 0 ;
   while( $input = <BOT> ){
      $bot[$i] = $input ;
      $i++ ;
   }
   close( BOT ) ;

   &jcgi::print_header( "Content-type", "text/html;charset=UTF-8" ) ;
   print "@top @html @bot" ;

}

################################Default Mode########################################
#If a mode other than add or delete is indicated, try to deal with it by sending the user
#back to the calendar.
else{
   &jcgi::print_header( "Location", "$cgiurl?lang=$lang&db=$dbname&month=$prevmonth&year=$prevyear" ) ;
}

