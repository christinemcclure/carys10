#!/usr/bin/perl

package dnfunc ;
require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = qw(dn_open dn_select dn_add dn_delete) ;
@EXPORT_OK = qw(%database $cur_dbfile $isDBopen @fieldlist @recordlist) ;

##############################################################################
# Datanet - perl database designed to be used as a back end for CGI programs.
#   by Jay Eckles
# Copyright 2004 Jay Eckles
# $Id: dnfunc.pm,v 1.10 2006/08/15 17:52:30 espergreen Exp $
# Copyright 2004 Jay Eckles
# This file is licensed under the GPL version 2 and is provided without warranty.
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
#      10-24-97, 2:22 A.M.
#   modified 8-12-98 1:38 P.M.
#
# These opening comments are the only documentation that exists for this
# software.  If you require further help, explanation, etc. of this software,
# please feel free to contact me by email at j.eckles@computer.org
#
# This is the dnfunc module, a Perl module that can be used by any perl
# script to make use of the datanet functions.  The functions included are
# dn_open (to open a database), dn_select (to select something from the
# database), and dn_add (to add a record to the database).  Plans are in the
# works for functions to edit records, delete records, sort records (a
# priority) and perhaps a rework of the select function.
#
# Description of functions:
#
# dn_open( filename )
#
#       This function opens the file "filename" which is assumed to be a
#       datanet database and loads the file into an associative array.
#       The array is store in such a way as the elements can be retrieved by
#       concatenating the the unique record key and a field.
#
#       Immeidately after the file is opened, it is locked exclusively using
#       a call to flock().  This will prevent concurrent reading from the
#       file.
#
#       The open function will return "success" if the database is
#       successfully opened and loaded, "failure" otherwise.  The assc.
#       array will be stored in an variable named database (%database).
#       It also sets a flag variable called $isDBopen to a true value (0) if
#       it is successful.  This value is set to a false value (1) if
#       dn_open has not yet been called or if dn_open returns "failure"
#       If dn_open cannot open the indicated database file for reading,
#       it returns "fatal_open_error" instead of "failure", but $isDBopen
#       still evaluates to false.
#
#       Opening a second database automatically closes the first.
#
# dn_select( what, [param1], [param2] )
#
#       This function selects something from the database.  What type of
#       information is selected from the database is determined by "what".
#       Please note: dn_select will return "failure" upon any error,
#       including failure to find the information requested.
#
#       Possible values for "what" include:
#               RECORDLIST, which requires no more parameters and returns a
#                  list of the record keys in the current database
#               FIELDLIST, which requires no more parameters and returns a
#                  list of the fields in the database (the general categories,
#                  not specific values for any given record).
#               ONEFIELD, which requires two more parameters, a record key
#                  and a field.  It returns the field indicated for the
#                  record indicated.  The order for the parameters passed
#                  to dn_select in this case MUST be ONEFIELD, record
#                  key, field.
#               AllFIELDS, which requires one more parameter, a field.
#                  It returns a list of the values of the indicated field
#                  for all records in the order in which the records appear
#                  in the database.
#               RECORD, which requires one more parameter, a record key.
#                  It returns the values for all fields of the record
#                  indicated in the form of a single line separated by pipes
#                  ( | ).
#               EXPLICIT, which requires one more parameter and is used only
#                  for implementation testing purposes.
#
# dn_add( key, record )
#
#       This function will either add a record to the database if a record
#       with the key given in "key" does not exist, or if a record with that
#       key does exist, it will be replaced with the recordstring given in
#       "record".
#
#       Immediately after the file is opened, it is locked exclusively using
#       a call to flock().  This will prevent concurrent processes from
#       simulatenously writing to the file, which will (and has in past
#       applications) destroy the database file resulting in a total loss of
#       data.
#
# dn_delete( key )
#       This function will delete the record from the database with the specified
#       key.  If a record with this key does not exist in the currently open
#       database, failure will be returned.  If the record is successfully
#       deleted, success will be returned.
#
#       Immediately after the file is opened, it is locked exclusively using
#       a call to flock().  This will prevent concurrent processes from
#       simulatenously writing to the file, which will (and has in past
#       applications) destroy the database file resulting in a total loss of
#       data.
#
# Note than in addition to the functions available to be called, the database
# generated in memory by dn_open is in the form of an associative array, and
# that associative array may be dealt with directly in a script using this
# module by calling it appropriately, %dnfunc::database.
##############################################################################

$cur_dbfile ;

# This function opens the file specified, reads the first line of the file
# which contains the list of fields for that database, then reads the rest
# of the lines, splits it up into an array of words, then puts those words
# into an associative array that is the database.  Any field for any record
# can then be selected using the line
# $info = $database{ $recordname.$fieldname } ;

sub dn_open{
   $dbname = $_[0] ;

   open( DBFILE, "$dbname" ) || return "fatal_open_error" ;
   flock( DBFILE, 2 ) ;
   $cur_dbfile = $dbname ;
# the first line is the field list
   $input = <DBFILE> ;
   $input =~ s/^\s+|\s+$//g ;
   @fieldlist = split( /\|/, $input ) ;
# there has to be at least one field...
   if( @fieldlist > 0 ){
      $recordcount = 0 ;

# now read in the rest of the file, one line (record) at a time
      while( $input = <DBFILE> ){

         # eliminate leading and trailing spaces
         $input =~ s/^\s+|\s+$//g;

         # split line into words (fields are pipe delimited)
         @words = split( /\|/, $input ) ;

         # recordlist is a list containing each of the record keys...the
         # key is required to be the first field.
         $recordlist[$recordcount++] = $words[0] ;

         # now add each of the "words" to the assc. array database
         for( $i = 0; $i < @words; $i++ ){
            $database{$words[0].$fieldlist[$i]} = $words[$i] ;
         }
      }
      close( DBFILE ) ;
      $isDBopen = 1 ;
      return "success" ;
   }
   else{
      close( DBFILE ) ;
      return "failure" ;
   }
}

# Ex. of calling dn_select:
# @results = dn_select( "ONEFIELD", "Rosemark", "Mascot" ) ;

sub dn_select{
   @words = @_ ;
   @list ;
   $field ;

   if( $words[0] eq "RECORD" ){
      for( $i = 0; $i < @fieldlist; $i++ ){
         $list[$i] = $database{$words[1].$fieldlist[$i]} ;
      }
      if( @list > 0 ){
         return @list ;
      }
      else{
         return "failure" ;
      }
   }
   elsif( $words[0] eq "ONEFIELD" ){
      $field = $database{ $words[1].$words[2] } ;
      if( $field ne "" ){
         return $field ;
      }
      else{
         return "failure" ;
      }
   }
   elsif( $words[0] eq "ALLFIELDS" ){
      for( $i = 0; $i < @recordlist; $i++ ){
         $list[$i] = $database{$recordlist[$i].$words[1]} ;
      }
      if( @list > 0 ){
         return @list ;
      }
      else{
         return "failure" ;
      }
   }
   elsif( $words[0] eq "RECORDLIST" ){
      if( @recordlist > 0 ){
         return @recordlist ;
      }
      else{
         return "failure" ;
      }
   }
   elsif( $words[0] eq "FIELDLIST" ){
      if( @fieldlist > 0 ){
         return @fieldlist ;
      }
      else{
         return "failure" ;
      }
   }
   elsif( $words[0] eq "EXPLICIT" ){
      $field = $database{ $words[1] } ;
      if( $field ne "" ){
         return $field ;
      }
      else{
         return "failure" ;
      }
   }
   else{
      return "failure" ;
   }
}

sub dn_add{

   $key = $_[0] ;
   $recordstring = $_[1] ;

   $pattern = "^$key" ;
   $found = 0 ;

# read in the contents of the database file, one line (record) at a time.
# if you find the key, replace the line in memory.  if you don't, just add
# the line to the end.

   open( DBFILE, "$cur_dbfile" ) || return "$cur_dbfile open for reading failure\n" ;
   flock( DBFILE, 2 ) ;
   $i = 0 ;
   while( $input = <DBFILE> ){
      if( $input =~ /$pattern/ ){
         $dbfile[$i] = $recordstring."\n" ;
         $found = 1 ;
      }
      else{
         $dbfile[$i] = $input ;
      }
      $i++ ;
   } #end loop
   if( $found == 0 ){
      $dbfile[$i] = $recordstring."\n" ;
   }
   close( DBFILE ) ;

# now just write the database back to the file from memory
   open( DBFILE, ">$cur_dbfile" ) || return "open $cur_dbfile for writing failure" ;
   flock( DBFILE, 2 ) ;
   for( $i=0; $i<@dbfile; $i++ ){
      print DBFILE "$dbfile[$i]" ;
   }
   close( DBFILE ) ;
   $open_status = dn_open( $cur_dbfile ) ;
   return "success" ;
}

# note that this function is very similar to dn_add.
sub dn_delete{
   $key = $_[0] ;
   $pattern = "^$key" ;
   $found = 0 ;

# read in the contents of the database file, one line (record) at a time.
# if you find the key, delete the line in memory.  if you don't, just add
# the line to the end.

   open( DBFILE, "$cur_dbfile" ) || return "$cur_dbfile open for reading failure\n" ;
   flock( DBFILE, 2 ) ;
   $i = 0 ;
   while( $input = <DBFILE> ){
      if( $input =~ /$pattern/ ){
         #print STDERR "found pattern in dn_delete\n" ;
         $found = 1 ;
      }
      else{
         $dbfile[$i] = $input ;
         $i++ ;
      }
   } #end loop
   if( $found == 0 ){
      #print STDERR "didn't find item we were trying to delete\n" ;
# return a message of failure if the key is not found in the file
      return "failure" ;
   }
   close( DBFILE ) ;

# now just write the database back to the file from memory
   open( DBFILE, ">$cur_dbfile" ) || return "open $cur_dbfile for writing failure" ;
   flock( DBFILE, 2 ) ;
   for( $i=0; $i<@dbfile; $i++ ){
      print DBFILE "$dbfile[$i]" ;
   }
   close( DBFILE ) ;
# recreate the database hash to effect the change.
   $open_status = dn_open( $cur_dbfile ) ;
   #print STDERR "database rewritten and reopened.\n" ;
   return "success" ;
}

1;
