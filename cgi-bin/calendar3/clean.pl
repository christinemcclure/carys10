#!/usr/bin/perl
# clean.pl
# This file is released to the public domain and is provided with no warranty whatsoever.

use dnfunc ;

print "This will delete orphan entries in a CGI Calendar database.\n" ;
print "Enter the name of the database to clean (usually calendar.db)\n" ;
$filename = <STDIN> ;
dn_open( "$filename" ) ;
if( $dnfunc::isDBopen ){
   print "Database open.\n" ;

   @fieldlist = dn_select( "FIELDLIST" ) ;
   print "Fieldlist: @fieldlist\n" ;
   @keys = dn_select( "RECORDLIST" ) ;
   print "Got keys.\n" ;

   foreach $key (@keys){
      $summary = $dnfunc::database{$key.$fieldlist[1]} ;
      if( $summary eq "" ){
         dn_delete( $key ) ;
         print "Deleted record with key $key\n" ;
      }
   }
   print "Finished.\n" ;
}
else{
   print "Problem opening database.  Finished.\n" ;
}
