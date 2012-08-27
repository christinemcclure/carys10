#!/usr/bin/perl
#this program is released into the public domain and is provided with no warranty whatsoever.

%months = ("January"=>1,"February"=>2,"March"=>3,"April"=>4,"May"=>5,"June"=>6,"July"=>7,"August"=>8,"September"=>9,"October"=>10,"November"=>11,"December"=>12) ;

open( FILE, "calendar.db" ) || die "Couldn't open calendar.db\n" ;

@newfile ;
$i = 0 ;
while( $line = <FILE> ){
   foreach $key (keys(%months)){
      $line =~ s/$key/-$months{$key}-/g ;
   }
   $newfile[$i] = $line ;
   $i++ ;
}

close( FILE ) ;

open( FILE, ">calendar.db" ) || die "Couldn't open calendar.db for writing\n" ;
for( $j=0; $j<@newfile; $j++ ){
   print FILE $newfile[$j] ;
}
close( FILE ) ;
