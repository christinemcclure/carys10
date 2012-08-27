#!/usr/bin/perl

use utf8 ;

require jcgi;
require dataaccess ;
require calendar ;
require jconfig ;
require language ;

&jconfig::loadConfig() ;

$cgiurl = $jconfig::value{"cgiUrl"} ;

#############################################################################
#Viewday.cgi
# $Id: viewday.cgi,v 1.15 2006/08/15 18:15:42 espergreen Exp $
# Copyright 2004 Jay Eckles
#    CSS class names used in HTML Copyright Isaac McGowan, used under GPL.
# This file is licensed under the GPL version 2 and is provided without warranty.
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
# This cgi script is used as a part of the CGI Calendar system, a collection
# of perl scripts and modules with the purpose of creating a web-based
# group event calendar.
#
# This script's job is to 1. display information for all events on given day
#	       -OR-  		  2. display information for one given event on day
# Which event(s) should be shown is communicated to the script via
# CGI.  The following is a list of the name and value pairs that
# Viewday.cgi must receive; the order in which they must be received is of
# no importance.
# If a name/value pair is optional, it is listed in square brackets ([]).
# if multiple values are possible for a name, all optional values are
# listed in parentheses (()), and spearated by pipes (|)
#
# mode=(all|one)
# month=an integer greater than or equal to 1 and less than or equal to 12
# date=an integer greater than or equal to 1 and less than or equal to 31
# year=a positive integer
# [summary=a string containing no newline characters]
#
# Note that summary is optional only if the value of mode is "all".  Providing
# a value for summary when the mode is "all" will have no effect.  Not providing
# a value for summary when the mode is "one" will cause the script to go into
# "all" mode.
#
# These name/value pairs may be passed to the cgi program using either the
# GET or POST methods.  The information is retrieved by calling a function
# found in the jcgi.pm module.
#
# $Log: viewday.cgi,v $
# Revision 1.15  2006/08/15 18:15:42  espergreen
# html is now valid
#
# Revision 1.14  2006/08/15 17:40:44  espergreen
# fixed html for opera
#
# Revision 1.13  2005/09/15 15:09:41  ecklesweb
# bug fix for multiple calendar databases
#
################################################################################

#retrieve the name/value pairs via a function made available by cgi.pm
@input = &jcgi::retrieve_input() ;

#setup text
$lang = $jcgi::in{"lang"} ;
if( $lang eq "" ){
   $lang = $jconfig::value{"defaultLanguage"} ;
}
if( $lang eq "" ){
   $lang = "en-us" ;
}
&language::loadText( $lang ) ;

#filename of the calendar database
&dataaccess::set_datasource( $jcgi::in{"db"}  );
$dbname = $jcgi::in{"db"} ;

&dataaccess::open_database() ;

$mode = $jcgi::in{"mode"} ;

$month = $jcgi::in{"month"} ;

$date = $jcgi::in{"date"} ;

$year = $jcgi::in{"year"} ;

$summary = $jcgi::in{"summary"} ;

#if no summary is given, then the mode must be set to "all"
if( $summary eq "" ){
   $mode = "all" ;
}

#create a key based on the date given...key is in format dd-mm-yyyy
$key = $date."-".$month."-".$year ;

@day_record = &dataaccess::get_events( $key ) ;
@day_record = sort calendar::timeCompare @day_record ;

foreach $record (@day_record) {
#print STDERR "event for $key: $record->{'summary'}\n" ;
   push( @events, $record->{'summary'} ) ;
   @expl_decoded = &jcgi::decode( $record->{'details'} ) ;
#print STDERR "encoded: $record->{'details'}; num items: @expl_decoded; string $expl_decoded[0]\n" ;
   push( @expls, $expl_decoded[0] ) ; #explanation is url encoded
   push( @times, $record->{'when'} ) ;
   @loc_decoded = &jcgi::decode( $record->{'location'} ) ;
   push( @location, $loc_decoded[0] ) ; #location is url encoded
}

$html_date = "<span class=date_header>$language::monthnames[$month-1] $date, $year</span>\n" ;
$html_addlink = "<a
href=\"addevent/addevent.cgi?lang=$lang&amp;db=$dbname&amp;mode=gen&amp;month=$month&amp;date=$date&amp;year=$year\"><img src=\"$jconfig::value{'addGifUrl'}\" border=0 alt=\"$language::addgifalt\"></a>\n";
$html_returnlink = "<a href=\"$cgiurl?lang=$lang&amp;db=$dbname&amp;month=$month&amp;year=$year\" class=footprint>$language::return</a>\n" ;
$html_table = "" ;

#if( $events[0] ne "" ){
   $html_table .= "
      <div align=center>
      <table border=1 cellpadding=2 cellspacing=0 width=\"75%\">
      <tr>
      <td></td>
      <td class=column_header>$language::what</td>
      <td class=column_header>$language::when</td>
      <td class=column_header>$language::where</td>
      <td class=column_header>$language::details</td>
	  <td></td>
   " ;
########################################All Mode#############################################
   if( $mode eq "all" ){
#for each event on the date,
      for( $i=0; $i < @events; $i++ ){
         $html_table .= create_tablerow( $month, $date, $year, $times[$i],
$events[$i], $expls[$i], $location[$i] ) ;
      }#end for loop
   } #end if($mode eq "add")

   elsif( $mode eq "one" ){
#######################################One Mode##########################################

      $match = 1 ;

#if the summary entered matches a summary found in the events list, we'll
#display the parts of events, expls, and times with the same index.
      for( $i=0; $match == 1 && $i<@events; $i++ ){
         if( $summary eq $events[$i] ){
            $match = 0 ;
         }#end if($summary eq $events[$i]
      }#end for loop

#if the summary match is found, create the table with just one row for that event
      if( $match == 0 ){
         $i -= 1 ;
         $html_table .= create_tablerow( $month, $date, $year, $times[$i],
$events[$i], $expls[$i], $location[$i] ) ;
      }#end if($match)
   }#end elsif(mode=one)

#}#end if( @events > 0 )
if( $events[0] eq "" ){
   $html_table .= "<tr><td valign=top align=center width=40>$html_addlink</td>"."<td colspan=5><div align=center>$language::noevents</div></td>" ;
}
#close the table
   $html_table .="
      </table></div>
   " ;
######################################Default Mode########################################
#If a mode other than all or one is indicated, try to deal with it by
#sending the user an error message
if( $mode ne "all" && $mode ne "one" ){
   &jcgi::return_error( "The mode sent to viewday.cgi, \"$mode\", is invalid." );
}

######################################Print HTML##########################################

#open top.html and read it into memory
open( HTML, "top.html" ) ;
$i = 0 ;
while( $input = <HTML> ){
      if( $input =~ /<LINK REL=stylesheet TYPE=text\/css HREF=\/calendar.css>/ ){
	     if( $jconfig::value{"cssUrl"} ne "" ){
			$input = "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"".$jconfig::value{"cssUrl"}."\">" ;
		 }
	  }
   $top[$i] = $input ;
   $i++ ;
}
#close top.html once it is read into memory
close( HTML ) ;
#open bot.html and read it into memory
open( HTML, "bot.html" ) ;
$i = 0 ;
while( <HTML> ){
   $bot[$i] = $_ ;
   $i++ ;
}
#close bot.html once it is read into memory
close( HTML ) ;

#now print to stdout the information from top.html, all the code we've developed
#in this script, and the information from bot.html.
   &jcgi::print_header( "Content-type", "text/html;charset=UTF-8" ) ;

   print "
      @top
      <div align=left>
      $html_date $html_returnlink
      </div>
      <br>
      $html_table
      <br>
      @bot
   " ;

sub create_tablerow(){

$month = $_[0] ;
$date = $_[1] ;
$year = $_[2] ;
$time = $_[3] ;
$event = $_[4] ;
$expl = $_[5] ;
$locat = $_[6] ;

$string = "" ;
#start a new row
         $string .= "<tr>\n" ;
#create a cell with the delete event button
         $temp = &jcgi::encode( $event ) ;
         $string .= "
            <td valign=top align=center width=40>$html_addlink<a
href=\"addevent/addevent.cgi?lang=$lang&amp;db=$dbname&amp;mode=delete&amp;month=$month&amp;date=$date&amp;year=$year&amp;summary=$temp\"><img src=\"$jconfig::value{'delGifUrl'}\" border=0 alt=\"$language::deletegifalt\"></a>
            </td>
         " ;
#create a cell with the event name
         $string .="
            <td valign=top>
            $event
            </td>
         " ;
#create a cell with the time
         $string .="
            <td valign=top>
            $time
            </td>
         " ;
#create a cell with the location
        $string .="
            <td valign=top>
            <script type=\"text/javascript\">document.write( unescape( \"$locat\" ) );</script>
            </td>
        " ;
#create a cell with the explanation
         $string .="
            <td valign=top>
            <script type=\"text/javascript\">document.write( unescape( \"$expl\" ) );</script>
            </td>
         " ;
#create a cell with the edit button
         $string .="
		    <td valign=top align=center width=40><a href=\"addevent/editevent.cgi?lang=$lang&amp;db=$dbname&amp;mode=gen&amp;month=$month&amp;date=$date&amp;year=$year&amp;summary=$temp\"><img src=\"$jconfig::value{'editGifUrl'}\" border=0 alt=\"$editgifalt\"></a>
			</td>
		" ;

return $string ;

}#end create_tablerow
