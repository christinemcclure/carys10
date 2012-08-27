#!/usr/bin/perl
use utf8;

require jcgi ;
require jconfig ;
require calendar ;
require dataaccess ;
require language ;

&jconfig::loadConfig() ;

if( $jconfig::value{'password'} eq "" || $jconfig::value{'password'} eq "password"){
   &jcgi::return_error( "You must change the password in jconfig.pm for CGI Calendar to work!" ) ;
   exit ;
}

$version = "3.0" ;

#############################################################################
#Index.cgi
# $Id: index.cgi,v 1.24 2006/08/15 18:09:43 espergreen Exp $
# Copyright 2004 Jay Eckles
# This file is licensed under the GPL version 2 and is provided without warranty.
# See http://www.gnu.org/copyleft/gpl.html for license details.
#    CSS class names used in HTML Copyright Isaac McGowan, used under GPL.
#
# This cgi script is used as a part of the CGI Calendar system, a collection
# of perl scripts and modules with the purpose of creating a web-based
# group event calendar.
#
# This script's job is to build a calendar in the form of an html table,
# including in the cell for each day any events found for that date in the
# calendar database.
#
# Which month and year should be loaded is communicated to the script via
# CGI communication.  The following is a list of the name and value pairs that
# Index.cgi must receive; the order in which they must be received is of
# no importance.
# If a name/value pair is optional, it is listed in square brackets ([]).
# if multiple values are possible for a name, all optional values are
# listed in parentheses (()), and spearated by pipes (|)
#
# month=an integer greater than or equal to 1 and less than or equal to 12
# year=a positive integer
#
# These name/value pairs may be passed to the cgi program using either the
# GET or POST methods.  The information is retrieved by calling a function
# found in the cgi.pm module.
#
# The generation of the calendar is accomplished by first finding the number
# of days in the month and the day of the week on which the month starts
# by calling functions provided by calendar.pm.  Then, an html table is
# constructed with 7 columns, and as many rows as necessary to fill out
# the calendar.  As each cell is created, the database is queried for events
# happening on the day that cell corresponds with - this is done by using the
# &dnfunc::dn_select function of dnfunc.pm.
#
# Originally authored by Jay Eckles <j.eckles@computer.org>.
# Contributors:
#     Many people from comp.infosystems.www.authoring.cgi - debugging tips,
#        many feature ideas, help in pointing out errors and poor code, etc.
#     Ken MacCuish <ken@pwhinc.com> - modified code to highlight the cell of the
#        table containing the current day with a color defined by the variable
#        $cell_today_color and any day with an event with a color defined by
#        the variable $cell_active_color
#
# $Log: index.cgi,v $
# Revision 1.24  2006/08/15 18:09:43  espergreen
# html is now valid
#
# Revision 1.23  2006/06/30 18:08:39  espergreen
# Unix shebangs
#
# Revision 1.22  2005/10/10 19:42:07  ecklesweb
# Note - windows shebangs.  Refined admin - password required
#
# Revision 1.18  2005/10/10 02:14:58  ecklesweb
# group functionality, added flags in jconfig
#
# Revision 1.17  2005/10/07 19:58:36  ecklesweb
# repeating events support - 3.0 alpha 1
#
# Revision 1.16  2005/09/15 15:09:41  ecklesweb
# bug fix for multiple calendar databases
#
# Revision 1.15  2005/04/19 02:47:56  ecklesweb
# change comments to license specifically under v2 of GPL
#
# Revision 1.14  2005/04/14 01:49:12  ecklesweb
# final 2.7 commits?
#
# Revision 1.13  2005/04/14 01:31:44  ecklesweb
# change way dates are represented so events can be shared across languages
#
# Revision 1.12  2005/04/14 01:16:47  ecklesweb
# remove print to STDERR, add use utf8 to .pm's
#
# Revision 1.11  2005/04/13 23:14:48  ecklesweb
# send UTF-8 content type header
#
# Revision 1.10  2005/04/02 23:47:31  ecklesweb
# added french, added language dropdown to index.cgi
#
# Revision 1.9  2005/04/01 01:58:35  ecklesweb
# utf-8 fix
#
# Revision 1.8  2005/04/01 01:51:29  ecklesweb
# multilingual enhancements
#
# Revision 1.7  2005/03/30 23:51:26  ecklesweb
# multilingual enhancements
#
# Revision 1.6  2005/02/25 01:34:52  ecklesweb
# finalizing 2.6 changes
#
# Revision 1.5  2004/11/27 19:18:16  ecklesweb
# ID and Log tags in index.cgi and calendar.pm
#
################################################################################

#initialize the language::monthnames and day lists

#retrieve the name/value pairs by using a cgi.pm function
@input = &jcgi::retrieve_input() ;
%input = %jcgi::in ;

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
if( $dbname eq "" ){
   $dbname = $jconfig::value{"defaultDb"} ;
}


$month = $input{"month"} ;
$year = $input{"year"} ;

#if no month or year is given, then use the current month or year according to the
#system clock.
@timelist = localtime( time() ) ;
if( $month eq "" ) {
   $month = $timelist[4] + 1 ;
}
if( $year eq "" ) {
   $year = $timelist[5]+1900 ;
}
$dayofmonth = $timelist[3] ;
$curmonth = $timelist[4]+1 ;
$curyear = $timelist[5]+1900;

#determine the language::monthname by using $month as an index to the language::monthnames list.
$language::monthname = $language::monthnames[$month-1] ;
$monthyear = $language::monthname.$year ;

#determine how many days are in the given month and on what day of the week
#that month starts.  These functions are provided by calendar.pm
$days_in_month = &calendar::days_in_month( $month, $year ) ;
$monthstart = &calendar::month_start( $month, $year ) ;


################Start creating the table that will be the calendar.####################

#the html code for the table will be stored as a string in the scalar variable $table
$table = "<tr>\n" ;

# print top row of calendar which holds days of week
for( $i=0; $i < 7; $i++ ){
   $table = $table."<td class=column_header>$language::day[$i]</td>\n" ;
}

# next row
$table = $table."<tr>\n" ;

# skip the appropriate number of days as indicated by the calendar::monthstart function
for( $i=0; $i < $monthstart; $i++ ){
   $table = $table."<td class=empty_day_cell></td>\n" ;
}

# in day_of_week, Sunday is 0, Saturday is 6.
$day_of_week = $monthstart ;

#now, we have got the table to the point where we know what day of the week we're on and
#we know that the next cell is the 1st of the month.  We can now start creating the cells
#for the days which means we begin to look for events in the database.

#$current_day is the day of the month we are currently working on
$current_day = 0 ;
# this loop creates the individual day cells on the calendar.
for( $i=1; $i <= $days_in_month ; $i++ ){
   $current_day++ ;
# find out if it's a new week and we need to start a new row
   if( !( $day_of_week % 7 ) ){
      $table = $table."<tr>\n" ;
   }


#create a key based on the date given...key is in format dd-mm-yyyy
   $key = $i."-".$month."-".$year ;

#retrieve the information for that day from the calendar database
   &dataaccess::open_database() ;

   @events = () ;

#print STDERR "events contains @events items\n" ;

#print STDERR "key is $key\n" ;

   @events = &dataaccess::get_events( $key ) ;

#print STDERR "events now contains @events items\n" ;
### sort the events/times by time
#   @events = &calendar::eventsort( @events ) ;
   @events = sort calendar::timeCompare @events ;

   @daysevents = () ;
   @times = () ;
   foreach $event (@events){
      push( @daysevents, $event->{'summary'} ) ;
      push( @times, $event->{'when'} ) ;
   }

# hilite the cell if it is today or there is an activity today
###begin Ken's code later modified by Jay###
   if ($i eq $dayofmonth && $curmonth eq $month && $year eq $curyear){
      $cellcolor="class=today_cell"
   }
   elsif( @daysevents > 0 ){
      $cellcolor="class=populated_day_cell" ;
   }
   else{
      $cellcolor="class=day_cell";
   }
# create the cell, include the day of the month - link day to viewday.cgi
   $table = $table."<td $cellcolor valign=top>
   <a href=\"viewday.cgi?lang=$lang&amp;mode=all&amp;month=$month&amp;date=$current_day&amp;year=$year&amp;db=$dbname\" class=day_number>$current_day</a>
   <br>" ;
###end Jay's modifications of Ken's code###
# if there's anything on this day, put it in the day's cell.
   if( @daysevents > 0 ){
      for( $j=0; $j < @daysevents; $j++ ){

####urlencode summary for transmission via get - encode from jcgi.pm
$enc_summary = &jcgi::encode( $daysevents[$j] ) ;
#link event to viewday.cgi
         $table .= "<a href=\"viewday.cgi?lang=$lang&amp;mode=one&amp;month=$month&amp;date=$current_day&amp;year=$year&amp;summary=$enc_summary&amp;db=$dbname\">";
# if there is a time, print the time after the summary of the event.  If
# there is no time given, don't print anything except the summary.
         if( $times[$j] =~ /^\D/ ){
            $table = $table."<span class=title_txt>$daysevents[$j]</span></a><br>\n" ;
         }
         else{
            $table = $table."<span class=title_txt>$daysevents[$j]</span></a> <br><span class=time_str>($times[$j])</span></a><br>\n" ;
         }
      }
   }
# close the cell
   $table = $table."</td>\n" ;
   $day_of_week = ($day_of_week + 1) % 7 ;
} #end of for loop: for( $i=1; $i <= $days_in_month ; $i++ )
#here, at the termination of the loop, we have created a cell for each day of the month.
#so we finish the table:
#$table = $table."</table>\n" ;

##loop through remaining days in last week to create empty cells...
$remaining_days = (7-$day_of_week) % 7 ;
for( $i=0; $i<$remaining_days; $i++ ){
   $table = $table."<td class=empty_day_cell></td>\n" ;
}
$table = $table."</tr>\n" ;

#create the form that will be at the top of the calendar to provide the "jump to month"
#functionality
$yearminus2 = $year - 2 ;
$yearminus1 = $year -1 ;
$yearplus1 = $year+1 ;
$yearplus2 = $year+2 ;
$yearplus3 = $year+3 ;
$form = "
<form action=\"index.cgi\" method=\"get\">
<input type=hidden name=db value=$dbname>
<input type=hidden name=lang value=$lang>
<select name=month class=month_select>
<option value=$month>$language::monthnames[$month-1]
<option value=1>$language::monthnames[0]
<option value=2>$language::monthnames[1]
<option value=3>$language::monthnames[2]
<option value=4>$language::monthnames[3]
<option value=5>$language::monthnames[4]
<option value=6>$language::monthnames[5]
<option value=7>$language::monthnames[6]
<option value=8>$language::monthnames[7]
<option value=9>$language::monthnames[8]
<option value=10>$language::monthnames[9]
<option value=11>$language::monthnames[10]
<option value=12>$language::monthnames[11]
</select>

<!--input type=text value=$year name=year size=4 class=year_input-->
<select name=year>
<option value=$yearminus2>$yearminus2
<option value=$yearminus1>$yearminus1
<option value=$year selected>$year
<option value=$yearplus1>$yearplus1
<option value=$yearplus2>$yearplus2
<option value=$yearplus3>$yearplus3
</select>

<input type=submit value=$language::govalue class=submit_button>
</form> " ;

######################################Print HTML########################################

#finally print the html page back to the client
#&jcgi::print_header function provided by cgi.pm
#append charset=UTF-8 so browsers will know to view multilingual pages as unicode and render properly
$type="text/html;charset=UTF-8" ;
&jcgi::print_header( "Content-type", $type ) ;

# if the calendar shown is January, then the previous month is December of
# the previous year (year-1).  Otherwise it is just the previous month of
# the same year (month-1)
if( $month == 1 ){
   $prevmonth = 12 ;
   $prevyear = $year-1 ;
}
else{
   $prevmonth = $month-1 ;
   $prevyear = $year ;
}
# similarly, if the calendar shown is December, the next month is January
# of the next year.  Otherwise it is month+1
if( $month == 12 ){
   $nextmonth = 1 ;
   $nextyear = $year + 1 ;
}
else{
   $nextmonth = $month+1 ;
   $nextyear = $year ;
}

#get list of groups before checking jconfig value - if there's only one
#db file, listGroups will change the jconfig enableGroups value to false,
#preventing the drop-down from being displayed.
@groups = &dataaccess::listGroups() ;
if( $jconfig::value{'enableGroups'} eq "true" ){
   $groupDropdown = "<form method=GET action=index.cgi name=groupform>
<input type=hidden name=lang value='$lang'>
<input type=hidden name=month value='$month'>
<input type=hidden name=year value='$year'>
<select name=db onChange=\"document.groupform.submit();\">\n" ;
   foreach $group (@groups){
      if( $dbname =~ /$group/ ){
         $groupDropdown .= "<option value='$group.db' selected>$group</option>\n" ;
      }
      else{
         $groupDropdown .= "<option value='$group.db'>$group</option>\n" ;
      }
   }
   $groupDropdown .= "</select>\n</form>\n" ;
}
else{
   $groupDropdown = "" ;
}

if( $jconfig::value{'enableLanguages'} eq "true" ){
   $languageDropdown = "<form action=\"index.cgi\" method=\"get\" name=langform>
<input type=hidden name=db value='$dbname'>
<input type=hidden name=month value='$month'>
<input type=hidden name=year value='$year'>
<select name=lang onChange=\"document.langform.submit();\">\n" ;
   foreach $key (sort by_value keys %language::availableLanguages) {
      if( $key eq $lang ){
         $languageDropdown .= "<option value='$key' selected>$language::availableLanguages{$key}</option>\n" ;
      }
      else{
         $languageDropdown .= "<option value='$key'>$language::availableLanguages{$key}</option>\n" ;
      }
   }
   $languageDropdown .= "</select>
</form>\n" ;
}
else{
   $languageDropdown = "" ;
}

sub by_value { $language::availableLanguages{$a} cmp $language::availableLanguages{$b}; }

if( $jconfig::value{'enableWebAdmin'} eq "true" ){
   $adminlink = "<form action=admin.cgi method=POST name='adminform'>
   <input type='hidden' name='password' value='' />
   <a href='#' onClick='document.adminform.password.value = prompt( \"Enter the administration password:\" );document.adminform.submit();'>[administration]</a>
   </form>" ;
}
else{
   $adminlink = "" ;
}

#$calendarinfo holds the html code for the calendar, including the table and
#the form we created earlier
$calendarinfo = "
<div align=center>
<table border=1 cellpadding=2 cellspacing=0 class=calendar_table>
<tr>
<td colspan=7>
<table border=0 width=\"100%\">
<tr>
<td class=arrows align=left><a
href=\"index\.cgi\?lang=$lang&amp;month=$prevmonth&amp;year=$prevyear&amp;db=$dbname\" class=prev_month_link><img src=\"$jconfig::value{'prevGifUrl'}\" class=prev_month_image border=0 alt=\"$language::prevgifalt\"></a><a
href=\"index\.cgi\?lang=$lang&amp;month=$nextmonth&amp;year=$nextyear&amp;db=$dbname\" class=next_month_link><img src=\"$jconfig::value{'nextGifUrl'}\" class=next_month_image border=0 alt=\"$language::nextgifalt\"></a>
</td>
<td class=date_header>
$language::monthname, $year
</td>
<td align=right valign=bottom class=date_nav_cell>
$form
</td>
</table>
</td></tr>

$table

<tr>
<td colspan=7 class=footprint>
<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">
<tr>
<td valign=middle align=left class=footprint>
<a href=\"http://cgicalendar.sourceforge.net\">CGI Calendar $version</a> by <a href=\"http\://www\.jayeckles\.com/\">Jay
Eckles</a>
</td>
<td align=right valign=top>
$groupDropdown
</td>
<td align=right valign=top>
$languageDropdown
</td>
<td valign=middle align=right class=footprint>
$adminlink
</td>
</tr>
</table>
</td>
</table>
</div>
" ;
#end $calendarinfo =...

#that html code we just developed goes inbetween the code found in two files,
#top.html and bot.html.  User's can customize the look of the calendar by editing
#top.html and bot.html.

#print STDERR "preparing top.html \n" ;
#print STDERR "$jconfig::value{'cssUrl'}\n" ;

#open top.html and read it into memory
open( HTML, "top.html" ) ;
$i = 0 ;
while( $input=<HTML> ){
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
print <<END
@top
$calendarinfo
@bot
END
;

