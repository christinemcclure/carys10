#!/usr/bin/perl
#
# jconfig.pm, a perl module used to store CGI Calendar configuration values.
# By Jay Eckles 
# Copyright 2004 Jay Eckles
# $Id: jconfig.pm,v 1.10 2006/06/30 18:08:39 espergreen Exp $
# This file is licensed under the GPL version 2 and is provided without warranty.  
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
#
# Created on 2/16/2004
# Last Modified 11/14/2004
#
# This module is used to configure CGI Calendar.  It's nice because you can define everything all in one
# place.  This file should be stored in the same directory as index.cgi.
#
# The comments below indicate what each $value{""} variable is for.  Using the examples given below, you
# should be able to figure out how to configure CGI Calendar for your installation.
#
# To make things modular, you'll see that I've used previously-defined variable names to define
# later names.  For example, 
# $value{"cgiUrl"} = $value{"server"}.$value{"cgiPath"}."index.cgi" ;
# means that cgiUrl is the server followed by the cgiPath followed by the string "index.cgi".

### Don't touch these next seven lines!
package jconfig ;
require Exporter ;
@ISA = qw( Exporter ) ;
@EXPORT = qw( loadConfig ) ;
@EXPORT_OK = qw(%value) ;

sub loadConfig{
### Don't touch the previous seven lines!

#OK, just below here is where you start changing configuration values.

#This is the password for web-based administration.  You MUST change this 
#password for CGI Calendar to work, even if you don't plan on using the
#web-based administration features.  You may not use the empty string ("")
#as the password.

   $value{"password"} = "usmania1";

#This flag determines whether web-based administration is enabled.  If so, an 
#link to the administration page will be displayed on the calendar, though
#the administrator password will be required to access it.

   $value{"enableWebAdmin"} = "true" ;


#This is the URL of your web server...Example: http://www.yourserver.com/ (the trailing '/' is important!)
   
   $value{"server"}="http://www.caryslounge.com/cgi-bin/" ;
   
#This is the path to the calendar3 directory on your web server.
#Example: if your calendar3 directory is at http://www.yourserver.com/cgi-bin/calendar3/, the value
#         would be cgi-bin/calendar3/ (the trailing '/' is important!)
   
   $value{"cgiPath"}="calendar3/" ;
   
#The path to index.cgi.  If you set the previous two variables correctly, you probably don't need to 
#change this one.  $value{"cgiUrl"} should resolve to something like
#http://www.yourserver.com/cgi-bin/calendar3/index.cgi
   
   $value{"cgiUrl"} = $value{"server"}.$value{"cgiPath"}."index.cgi" ;
   
#This is the URL for add.gif.  If your server is set up like mine, you can't serve up images
#from the cgi-bin.  I have to copy the gifs to another location on the web server.  I serve mine up from 
#the web root.  $value{addGifUrl} should resolve to something like
#http://www.yourserver.com/images/add.gif
   
   $value{"addGifUrl"} = $value{"server"}."images/add.gif" ;
#Ibid for delete.gif
   $value{"delGifUrl"} = $value{"server"}."images/delete.gif" ;
#Ibid for edit.gif
   $value{"editGifUrl"} = $value{"server"}."images/edit.gif" ;
#Ibid for next.gif
   $value{"nextGifUrl"} = $value{"server"}."images/next.gif" ;
#Ibid for previous.gif
   $value{"prevGifUrl"} = $value{"server"}."images/previous.gif" ;
   
#This is the URL for the calendar stylesheet.  It doesn't have to be named calendar.css, and it can be
#anywhere on the web.  I serve mine up from the document root.  $value{"cssUrl"} should resolve to something
#like
#http://www.yourserver.com/css/calendar.css
   
   $value{"cssUrl"} = $value{"server"}."../styles/calendar.css" ;

#This flag determines whether multiple languages is enabled.  If you enable it,
#the user will be able to choose which language he or she wishes to use
#via a drop-down menu.  If you disable it, the calendar will only be displayed
#in the default language specified below.
#When "true", multi language feature is enabled.
#When "false, multi language feature is disabled.

$value{'enableLanguages'} = "true";
   
#This is the default language to use.  See language.pm for the list of 
#defined languages.  "en-us" is US English.

$value{'defaultLanguage'} = "en-us";

#This flag determines whether the "groups" feature is enabled.  If you
#enable it, the user will be able to choose which .db file he or she wishes
#to view (except empty.db, which is not shown to the user as an option).
#For example, if you had Accounting.db, Human_Resources.db, and Sales.db, the
#user would be able to choose whether to view events for the "groups"
#Accounting, Human_Resources, or Sales.  
#When "true", the user is able to choose among groups.
#When "false", the user is unable to choose among groups and only the 
#default database is displayed.
#
#NOTE: if only one *.db file (not counting empty.db) is present, groups 
#will be automatically disabled, regardless of the value set here.   

   $value{"enableGroups"} = "true" ;

   
#This is the default database to use.  If no db is specified on the querystring, this is the database that
#will be used.  It doesn't necessarily have to be calendar.db.  You do NOT need to put any server information
#before the name of the file.  This is the file name only (no http://, no /, etc.)
   
$value{'defaultDb'} = "calendar.db";

#That's all, folks.
   return %value ;
}
