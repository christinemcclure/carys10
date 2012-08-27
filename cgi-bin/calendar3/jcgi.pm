#!/usr/bin/perl
#
# $Id: jcgi.pm,v 1.6 2005/10/07 19:58:36 ecklesweb Exp $
#
# cgi.pm, a perl module that provides the following functions:
#    1. @list retrieve_input() - retrieve, decode, and split into
#       name/value pairs input via either the POST or GET methods
#       This function now makes available a hash where the name is the key
#       and the value is the value.  Ex: $in{"name"} eq "Jay"
#    2. print_header( $scalar, $scalar ) - print a correct http header.
#       The first argument passed to it should be a http header type
#       (like "Content-type") and the second should be a value (like
#       "text/html") 
#    3. $scalar encode( $scalar ) - returns a url encoded version of the
#       string passed to it.
#    4. @list decode( $scalar ) - decode and split by ampersand the 
#       string passed to it.
#    5. return_html_file( $scalar [,$scalar, $scalar [,...]] ) - return
#       to the client via stdout the html file specified by the first 
#       argument, replacing each occurence of the second argument, if any,
#       with each successive argument after the second.
#
# By Jay Eckles - original work (except line as noted by Lincoln D. Stein)
# Copyright 2004 Jay Eckles
# This file is licensed under the GPL version 2 and is provided without warranty.  
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
#
# Created on 11/4/97
# Modified on 5-21-98

package jcgi ;
require Exporter ;
@ISA = qw( Exporter ) ;
@EXPORT = qw(retrieve_input print_header return_html_file encode decode return_error) ;
@EXPORT_OK = qw(@returnlist $page) ;

#This function has always been included but never worked before.  Now it
#does.  It can be called by an including script...it is not called by
#any function in this package.  It takes as its argument a string and
#returns the same string urlencoded
sub encode{
   $string = $_[0] ;
#this line copied and pasted from CGI.pm by Lincoln D. Stein
   $string =~ s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/eg;
   return $string ;
}

#This function is called by getinput and postinput for decoding a
#query string.
sub decode{
   @temp = @_ ;
   $querystring = $temp[0] ;
#split the query string up into name/value pairs
   @querystring = split( /&/, $querystring ) ;

#for each name/value pair, url decode it.
   for( $i=0; $i < @querystring; $i++ ){
      $querystring[$i] =~ s/\+/ /g ;
      $querystring[$i] =~ s/%([\da-f]{1,2})/pack( C, hex( $1 ) )/eig ;
   }
# querystring is now a list whose elements are name/value pairs
# Ex: @querystring == ( name=value, name2=value2, name3=value3 )
# All URL encoding has been decoded.
   
   for( $i=0; $i<@querystring; $i++ ){
      ($key,$value) = split( /=/, $querystring[$i] ) ;
      $in{$key} = $value ;
   }
   return @querystring
}

#This function is called by retrieve_input if the method is get
sub getinput{
#get the query string from the environmental variable
   $querystring = $ENV{ "QUERY_STRING" } ;
#urldecode it
   @returnlist = decode( $querystring ) ;
   return @returnlist ;
}

#This function is called by retrieve_input if the method is post
sub postinput{
#get the query string from stdin
   $querystring = <STDIN> ;
#urldecode it
   @returnlist = decode( $querystring ) ;
   return @returnlist ;
}

#This function can be called from an including script.  It receives the 
#input via either get or post method.
sub retrieve_input{
#determine the method used
   $method = $ENV{ "REQUEST_METHOD" } ;
   $method =~ tr/A-Z/a-z/ ;
#if the post method is used, call the postinput func
   if(  $method eq "post" ){
      @returnlist = postinput() ;
   }
#if the get method is used, call the getinput func
   elsif( $method eq "get" ){
      @returnlist = getinput() ;
   }
#if the method is neither get nor post, this is how I return an error
   else{
      @returnlist = ("unknown method") ;
   }
   return @returnlist ;
}

# The print_header function takes as its arguments two things:
# 1. the type of HTTP header to print such as "Content-type"
# 2. the value of the header such as "text/html" for a "Content-type" header
# The function returns nothing.

sub print_header{
   @temp = @_ ;
   $header_type = $temp[0] ;
   $header_value = $temp[1] ;

   print "$header_type: $header_value\n\n" ;   
}

#This function will return to a client the contents of the html file
#specified.  You may also add as a second argument to the function a 
#variable containing a pattern to match, such as "<!--*-->".  Any
#time this pattern is found in a line, the next argument passed
#to this function will replace it.  For example:
#if I had an html file that looked like this:
#<html><body><!--*--><hr><!--*--></body></html>
#and called this function like this:
#return_html_file( $filename, "<!--*-->", "Above", "Below" ) ;
#the html returned to the client would look like this:
#<html><body>Above<hr>Below</body></html> 
#This is useful if you want to return a page that contains only
#a small amount of dynamic content-you can create a static page
#with markers of your choice indicating where the dynamic content
#goes, then call this function from your cgi to add the dynamic content
#to it.

sub return_html_file{
   @temp = @_ ;
   $filename = $temp[0] ;
   $marker = $temp[1] ;
   if( $filename eq "" ){
      $filename = "default.html" ;
   }
   open( HTML, $filename ) || die "open error";

   $page = "" ;
   $specialtags = 2 ;
   while( $inputline = <HTML> ){
      if( $inputline =~ /$marker/ ){
         $page = $page.$temp[$specialtags] ;
         $specialtags++ ;
      }
      else{
         $page = $page.$inputline ;
      }
   }

   close( HTML ) ;
   
   print_header( "Content-type", "text/html" ) ;
   print $page ;
}

# a subroutine to return a message to the user indicating some error has occured then to
# make the program die.
sub return_error{
 
   print_header( "Content-type", "text/html" ) ;
 
   print "
      <html>
      <body>
      <h1>Sorry, but an error occured.</h1>
      <b>Here's what happened</b>:<br>
      $_[0]
      </body>
      </html>
   " ;
 
   die "Execution halted by return_error in cgi.pm - an error was indicated.\n" ;
}

sub debug(){
	my $message = shift() ;
	open( FILE, ">>DEBUG" ) || return ;
	print FILE $message."\n" ;
	close FILE ;
}
