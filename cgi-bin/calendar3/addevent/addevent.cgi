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
#Addevent.cgi
# $Id: addevent.cgi,v 1.20 2006/08/15 18:45:19 espergreen Exp $
# Copyright 2004 Jay Eckles
#    CSS class names used in HTML Copyright Isaac McGowan, used under GPL.
# This file is licensed under the GPL version 2 and is provided without warranty.
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
# This cgi script is used as a part of the CGI Calendar system, a collection
# of perl scripts and modules with the purpose of creating a web-based
# group event calendar.
#
# This script's job is to 1. add an event to the calendar database
#                         2. delete an event from the calendar database
#                         3. generate an html form for adding an event
# Which event should be added or deleted is communicated to the script via
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
# time=a string in the format hh:mm where hh is a one or two digit integer
#      greater than or equal to 1 and less than or equal to 12, and mm is
#      a two digit integer greater than or equal to 0 and less than or
#          equal to 59
# ampm=(AM|PM)
# summary=a string containing no newline characters
# [extended=a string containing no newline characters]
#
# These name/value pairs may be passed to the cgi program using either the
# GET or POST methods.  The information is retrieved by calling a function
# found in the cgi.pm module.
#
# The addition or deletion of the information from the database is accomplished
# by retrieving the current record for the date indicated, altering that record,
# then updating that record in the database by using the dn_add function
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
# $Log: addevent.cgi,v $
# Revision 1.20  2006/08/15 18:45:19  espergreen
# html is now valid
#
# Revision 1.19  2006/08/15 17:53:02  espergreen
# commented out debug lines
#
# Revision 1.18  2006/06/30 18:08:39  espergreen
# Unix shebangs
#
# Revision 1.17  2005/10/10 15:45:01  ecklesweb
# note - contains windows-style shebangs.  finalization of group dropdown.
#
# Revision 1.16  2005/10/07 19:58:38  ecklesweb
# repeating events support - 3.0 alpha 1
#
# Revision 1.15  2005/09/15 16:36:08  ecklesweb
# remove repeating code from addevent that's not ready for prime-time
#
# Revision 1.14  2005/09/15 15:09:41  ecklesweb
# bug fix for multiple calendar databases
#
#revision 1.13
#date: 2005/05/16 23:32:26;  author: ecklesweb;  state: Exp;  lines: +10 -2
#commit following reorg of CVS
#----------------------------
#revision 1.12
#date: 2005/04/19 02:47:57;  author: ecklesweb;  state: Exp;  lines: +2 -2
#change comments to license specifically under v2 of GPL
#----------------------------
#revision 1.11
#date: 2005/04/14 01:49:12;  author: ecklesweb;  state: Exp;  lines: +3 -5
#final 2.7 commits?
#----------------------------
#revision 1.10
#date: 2005/04/14 01:31:45;  author: ecklesweb;  state: Exp;  lines: +2 -2
#change way dates are represented so events can be shared across languages
#----------------------------
#revision 1.9
#date: 2005/04/14 01:16:48;  author: ecklesweb;  state: Exp;  lines: +4 -2
#remove print to STDERR, add use utf8 to .pm's
#----------------------------
#revision 1.8
#date: 2005/03/30 23:57:13;  author: ecklesweb;  state: Exp;  lines: +1 -0
#id tags for everyone
#----------------------------
#revision 1.7
#date: 2005/03/30 23:51:26;  author: ecklesweb;  state: Exp;  lines: +65 -19
#multilingual enhancements
#----------------------------
#revision 1.6
#date: 2005/02/25 01:34:53;  author: ecklesweb;  state: Exp;  lines: +3 -4
#finalizing 2.6 changes
#----------------------------
#revision 1.5
#date: 2004/11/27 19:28:30;  author: ecklesweb;  state: Exp;  lines: +3 -2
#Id and Log tags for all text-based files
#----------------------------
#revision 1.4
#date: 2004/11/16 03:37:51;  author: ecklesweb;  state: Exp;  lines: +0 -1
#Updated in-progress commit of data abstraction code.  First pass at editevent.cg
#i mod.
#----------------------------
#revision 1.3
#date: 2004/11/14 21:57:18;  author: ecklesweb;  state: Exp;  lines: +6 -23
#In progress commit of dataaccess; enough to get addevent.cgi to work
#----------------------------
#revision 1.2
#date: 2004/11/14 21:04:48;  author: ecklesweb;  state: Exp;  lines: +31 -78
#In progress commit of dataaccess; trying to get addevent.cgi to work.  Also fixe
#d gif references.
#----------------------------
#revision 1.1
#date: 2004/08/23 22:18:44;  author: ecklesweb;  state: Exp;
#branches:  1.1.1;
#Initial revision
#----------------------------
#revision 1.1.1.3
#
################################################################################
#print STDERR "entering addevent.cgi\n" ;

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

&dataaccess::set_datasource( $jcgi::in{"db"}  );
$dbname = $jcgi::in{"db"} ;

&dataaccess::open_database() ;

$mode = $jcgi::in{"mode"} ;

$month = $jcgi::in{"month"} ;

$date = $jcgi::in{"date"} ;

$year = $jcgi::in{"year"} ;

#create a key based on the date given...key is in format dd-mm-yyyy
$key = $date."-".$month."-".$year ;

########################################Add Mode#############################################
if( $mode eq "add" ){
   $time = $jcgi::in{"time"} ;

   $ampm = $jcgi::in{"ampm"} ;

   $summary = $jcgi::in{"summary"} ;

   $extended = &jcgi::encode( $jcgi::in{"extended"} ) ;

   $locat = &jcgi::encode( $jcgi::in{"location"} ) ;

   $period = $jcgi::in{"period"} ;

   $frequency = $jcgi::in{"frequency"} ;

   $duration = $jcgi::in{"duration"} ;

   if( $summary eq "" || $month eq "" || $date eq "" || $year eq "" ){
      &jcgi::return_error( "You must enter the month, date, year, and a summary for the event!<br>month: $month date: $date year: $year summary: $summary" ) ;
   }

#construct a new string that will be the record for the date
   $event = new Event ;
   $event->{'date'} = $key ;
   $event->{'summary'} = $summary ;
   $event->{'when'} = $time." ".$ampm ;
   $event->{'location'} = $locat ;
   $event->{'details'} = $extended ;
   $event->{'repeatperiod'} = $period ;
   $event->{'repeatfrequency'} = $frequency ;
   $event->{'repeatduration'} = $duration ;

&jcgi::debug( "Repeating? ".$jcgi::in{'repeats'} ) ;

   if( $jcgi::in{"repeats"} eq "" ){
      $status = &dataaccess::add_single_event( $event ) ;
   }
   else{
      $status = &dataaccess::add_repeating_event( $event ) ;
   }

#print STDERR "Status of add_single_event was $status\n" ;

#finally, send the user back to the calendar, loading the month and year that he added
#an event to.
   &jcgi::print_header( "Location", "$cgiurl?lang=$lang&db=$dbname&month=$month&year=$year" ) ;

} #end if($mode eq "add")

elsif( $mode eq "delete" ){

#######################################Delete Mode##########################################
   $summary = $jcgi::in{"summary"} ;

   $event = new Event ;

   $event->{'summary'} = $summary ;
   $event->{'date'} = $key ;

   &dataaccess::delete_single_event( $event ) ;

#finally, send the user back the the calendar, loading the month and year that he
#added an event to.
   &jcgi::print_header( "Location", "$cgiurl?lang=$lang&db=$dbname&month=$month&year=$year" ) ;
}

elsif( $mode eq "gen" ){
##################################Gen Mode###################################

   open( HTML, "addevent.html" ) ;

   $line = 0 ;
   $monthname = $language::monthnames[$month-1] ;
   while( $input = <HTML> ){
      if( $input =~ /^<input type=hidden name=db>/ ){
         $html[$line] = "<input type=hidden name=db value='$dbname'>\n" ;
      }
      elsif( $input =~ /^<input type=hidden name=lang>/ ){
         $html[$line] = "<input type=hidden name=lang value='$lang'>\n" ;
      }
      elsif( $input =~ /^<!--addtitle-->/ ){
         $html[$line] = $language::addtitle."\n" ;
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
      elsif( $input =~ /^<!--addvalue-->/ ){
         $html[$line] = "\"".$language::addvalue."\""."\n" ;
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

