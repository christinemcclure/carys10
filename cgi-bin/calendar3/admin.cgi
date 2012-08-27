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
#Admin.cgi
# $Id: admin.cgi,v 1.5 2006/06/30 18:08:39 espergreen Exp $
# Copyright 2005 Jay Eckles
#    CSS class names used in HTML Copyright Isaac McGowan, used under GPL.
# This file is licensed under the GPL version 2 and is provided without warranty.  
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
# This cgi script is used as a part of the CGI Calendar system, a collection
# of perl scripts and modules with the purpose of creating a web-based
# group event calendar.  
#
# This script's job is to allow the user to update configuration settings
# through a web-based interface
#
# mode=(gen|language|groupedit)
#
#
# $Log: admin.cgi,v $
# Revision 1.5  2006/06/30 18:08:39  espergreen
# Unix shebangs.  Expanded error messages.
#
# Revision 1.4  2005/10/18 20:19:21  ecklesweb
# Note: windows shebangs; Improvements to web-administration
#
# Revision 1.3  2005/10/10 20:11:36  ecklesweb
# Note - windows shebangs.  Various housecleaning - updated readme, function header comments
#
# Revision 1.2  2005/10/10 19:42:07  ecklesweb
# Note - windows shebangs.  Refined admin - password required
#
# Revision 1.1  2005/10/10 19:22:41  ecklesweb
# Note: windows-style shebangs. Initial web-based admin files
#
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

$mode = $jcgi::in{"mode"} ;
 
#if jconfig.pm isn't writable, there's no point in continuing
if( ! -w "jconfig.pm" ){
	&jcgi::return_error( "The configuration file is not writable, so web-based administration can't be used." ) ;
}
#if web-based admin isn't enabled, don't continue
if( $jconfig::value{"enableWebAdmin"} ne "true" ){
	&jcgi::return_error( "Web-based administration has not been enabled in the configuration file." ) ;
}
if( $jcgi::in{'password'} ne $jconfig::value{'password'} ){
	&print_pw_form() ;
}

if( $mode eq "gen" || $mode eq "" ){

	&print_form("") ;
}#end mode eq "gen"

elsif( $mode eq "language" ){

	$newlang = $jcgi::in{ 'lang' } ;
	if( $newlang ne "" && $newlang ne $jconfig::value{'defaultLanguage'} ){
		$status = &replace_jconfig_value( "defaultLanguage", $newlang ) ;
		if( $status ne "success" ){
			&print_form( "Update failed: $status" ) ;
		}
	}
	if( $jcgi::in{'enablelang'} ne "" && $jconfig::value{'enableLanguages'} ne "true" ){
		$status = &replace_jconfig_value( "enableLanguages", "true" ) ;
		if( $status ne "success" ){
			&print_form( "Update failed: $status" ) ;
		}
	}	
	if( $jcgi::in{'enablelang'} eq "" && $jconfig::value{'enableLanguages'} eq "true" ){
		$status = &replace_jconfig_value( "enableLanguages", "false" ) ;
		if( $status ne "success" ){
			&print_form( "Update failed: $status" ) ;
		}
	}
	&print_form( "Language change(s) made successfully." ) ;

}#end mode eq "language"

elsif( $mode eq "group" ){
	if( $jcgi::in{'group'} !~ /\.db$/ ){
		$jcgi::in{'group'} .= ".db" ;
	}
	$newgroup = $jcgi::in{ 'group' } ;
	if( $newgroup ne "" && $newgroup ne $jconfig::value{'defaultDb'} ){
		$status = &replace_jconfig_value( "defaultDb", $newgroup ) ;
		if( $status ne "success" ){
			&print_form( "Update failed: $status" ) ;
		}
	}
	if( $jcgi::in{'enablegroup'} ne "" && $jconfig::value{'enableGroups'} ne "true" ){
		$status = &replace_jconfig_value( "enableGroups", "true" ) ;
		if( $status ne "success" ){
			&print_form( "Update failed: $status" ) ;
		}
	}	
	if( $jcgi::in{'enablegroup'} eq "" && $jconfig::value{'enableGroups'} eq "true" ){
		$status = &replace_jconfig_value( "enableGroups", "false" ) ;
		if( $status ne "success" ){
			&print_form( "Update failed: $status" ) ;
		}
	}
	&print_form( "Group change(s) made successfully." ) ;
}#end mode eq "group"

elsif( $mode eq "groupedit" ){

	if( $jcgi::in{'editaction'} eq "New" ){
		#add group
		my $blank = "" ;
		open( EMPTY, "empty.db" ) || die &print_form( "Couldn't create the new group $jcgi::in{'newname'}.db: $!" ) ;
		while( $line = <EMPTY> ){
			$blank .= $line ;
		}
		close( EMPTY ) ;

		if( $jcgi::in{'newname'} =~ /^[\w ]+$/g ){
			open( NEW, ">$jcgi::in{'newname'}.db" ) || die &print_form( "Couldn't create the new group file $jcgi::in{'newname'}.db: $!" ) ;
			print NEW $blank ;
			close( NEW ) ;
			&print_form( "New group created." ) ;
		}
		else{
			&print_form( "Name for the new group is invalid.\n" ) ;
		}
	}
	elsif( $jcgi::in{'editaction'} eq "Delete" ){
		#delete group
		unlink( $jcgi::in{'group'} )  || die &print_form( "Couldn't delete group $jcgi::in{'group'}: $! " );
		&print_form( "Group deleted." ) ;
	}
	elsif( $jcgi::in{'editaction'} eq "Rename" ){
		#move group
		if( $jcgi::in{'rename'} ne "" and $jcgi::in{'rename'} =~ /^[\w ]+$/){
			#append .db to group name if it's not already there
			if( $jcgi::in{'group'} !~ /\.db$/ ){
				$jcgi::in{'group'} .= ".db" ;
			}
			$status = rename( $jcgi::in{'group'}, $jcgi::in{'rename'}.".db" ) ;
			if( $status == 1 ){
				if( $jconfig::value{'defaultDb'} eq $jcgi::in{'group'} ){
					&replace_jconfig_value( "defaultDb", $jcgi::in{'rename'}.".db" ) ;
				}
				&print_form( "Group renamed." ) ;
			}
			else{
				&print_form( "Rename failed." ) ;
			}
		}
		else{
			&print_form( "The new name for the group is invalid." ) ;
		}
	}
	elsif( $jcgi::in{'editaction'} eq "Make Default" ){
		&replace_jconfig_value( "defaultDb", $jcgi::in{'group'} ) ;
		&print_form( "Default group changed." ) ;
	}
	else{
		&jcgi::return_error( "An invalid action was specified.\n" ) ;
	}

}#end mode eq "groupedit"

else{
	&jcgi::return_error( "Invalid mode specified" ) ;
}

#Name: create_lang_list
#
#Description: Create the select element for the language drop-down
#
#Globals: %jconfig::value, %language::availableLanguages
#
#Arguments: None
#
#Returns: String with select element
#
#Author: Jay Eckles
#Date: 10/10/2005
#
#Modification History
#Author		Date		Modification
##
sub create_lang_list(){
	my $list = "";
	my $lang = "" ;

	$lang = $jconfig::value{ 'defaultLanguage' } ;

	$list = "<select name=lang>\n" ;
     	foreach $key (sort by_value keys %language::availableLanguages) {
      		if( $key eq $lang ){
         		$list .= "<option value='$key' selected>$language::availableLanguages{$key}</option>\n" ;
      		}
      		else{
         		$list .= "<option value='$key'>$language::availableLanguages{$key}</option>\n" ;      
      		}
   	} 
   	$list .= "</select>\n" ;
	
	return $list ;
}

#Name: create_group_list
#
#Description: Create the select element for the group drop-down
#
#Globals: %jconfig::value
#
#Arguments: size - number of groups to show in selection list at once
#
#Returns: String with select element
#
#Author: Jay Eckles
#Date: 10/10/2005
#
#Modification History
#Author		Date		Modification
##
sub create_group_list(){
	my $size = shift() ;
	my $list = "" ;
	my $curdef = "" ;
	my $defexists = "" ;
	my @groups = &dataaccess::listGroups() ;

	if( $size != 1 && @groups > $size ){
		$size = @groups ;
	}

	$curdef = $jconfig::value{ 'defaultDb' } ;

	$list = "<select name=group size=$size>\n" ;
	foreach $group (@groups){
		if( $curdef =~ /$group/ ){
			$list .= "<option value='$group.db' selected>$group</option>\n" ;
			$defexists = "true" ;
		}
		else{
			$list .= "<option value='$group.db'>$group</option>\n" ;
		}
	}
	$list .= "</select>\n" ;
	if( $defexists ne "true" ){
		$list .= "<br /><b><i>There is currently no default group set!</i></b>\n" ;
	}

	return $list ;
}

#Name: by_value
#
#Description: Helper method for sorting languages
#
#Globals: %language::availableLanguages
#
#Arguments: $a (implied) - comparitor 1, $b (implied) - comparitor 2
#
#Returns: -1 if a < b
#	   0 if a = b
#	   1 if a > b
#
#Author: Jay Eckles
#Date: 10/10/2005
#
#Modification History
#Author		Date		Modification
##
sub by_value { $language::availableLanguages{$a} cmp $language::availableLanguages{$b}; }

#Name: replace_jconfig_value
#
#Description: Update jconfig.pm with a new value for a config setting
#
#Globals: none
#
#Arguments: $setting - config setting to change
#           $value - new value to set for config setting
#
#Returns: "success" or a string describing the failure
#
#Author: Jay Eckles
#Date: 10/10/2005
#
#Modification History
#Author		Date		Modification
##
sub replace_jconfig_value(){
	my $setting = shift() ;
	my $value = shift() ;

	#read in jconfig.pm
	open( JCONFIG, "jconfig.pm" ) || return "can't open jconfig.pm for reading." ;
	while( $line = <JCONFIG> ){
		#if line contains the setting we're canging
		if( $line =~ /value\{.*$setting.*\}/ ){
			#update the value
			$newfile .= "\$value{'$setting'} = \"$value\";\n" ;
			#update the value in memory, too!
			$jconfig::value{$setting} = $value ;
		}
		else{
			#just copy lines that aren't related to the setting we're changing
			$newfile .= $line;
		}
	}
	close( JCONFIG ) ;

	#delete existing file before writing out the new one
	unlink( "jconfig.pm" ) ;
	#write out revised jconfig.pm
	open( JCONFIGW, ">jconfig.pm" ) || return "can't open jconfig.pm for writing." ;
	print JCONFIGW $newfile ;
	close( JCONFIGW ) ;

	return "success" ;
}

#Name: print_form
#
#Description: print the administration page to the browser
#
#Globals: %jconfig::value
#
#Arguments: $result - message to display at the top of the page
#
#Returns: None
#
#Author: Jay Eckles
#Date: 10/10/2005
#
#Modification History
#Author		Date		Modification
##
sub print_form(){
	my $result = shift() ;
   my @top, @html, @bot ;

   open( HTML, "admin.html" ) ;
   $i = 0; 
   while( $input = <HTML> ){
      if( $input =~ /<!--result-->/ && $result ne "" ){
         $input = "<b>".$result."</b><br /><br />\n" ;
      }
      if( $input =~ /<!--langlist-->/ ){
         $input = &create_lang_list() ;
      }
      if( $input =~ /<!--grouplist-->/ ){
         $input = &create_group_list(3) ;
      }
      if( $input =~ /<!--grouplistshort-->/ ){
         $input = &create_group_list(1) ;
      }
      if( $input =~ /<!--langbox-->/ ){
         if( $jconfig::value{'enableLanguages'} eq "true" ){
            $input = "<input type=checkbox name=enablelang checked />" ;
         }
	 else{
            $input = "<input type=checkbox name=enablelang />" ;
         }
      }
       if( $input =~ /<!--groupbox-->/ ){
         if( $jconfig::value{'enableGroups'} eq "true" ){
            $input = "<input type=checkbox name=enablegroup checked />" ;
         }
	 else{
            $input = "<input type=checkbox name=enablegroup />" ;
         }
      }
      $html[$i] = $input ;
      $i++ ;
   }
   close( HTML ) ;

   #read top.html into memory
   open( TOP, "top.html" ) ;
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

   #read bot.html into memory
   open( BOT, "bot.html" ) ;
   $i = 0 ;
   while( $input = <BOT> ){
      $bot[$i] = $input ;
      $i++ ;
   }
   close( BOT ) ;
   
#finally print the html page back to the client
#append charset=UTF-8 so browsers will know to view multilingual pages as unicode and render properly
$type="text/html;charset=UTF-8" ;
&jcgi::print_header( "Content-type", $type ) ;

   #print page to browser
   print "@top @html @bot" ;

}

#Name: print_pw_form
#
#Description: Print a form allowing the user to enter the administration password
#
#Globals: %jconfig::value
#
#Arguments: None
#
#Returns: Nothing
#
#Author: Jay Eckles
#Date: 10/10/2005
#
#Modification History
#Author		Date		Modification
##
sub print_pw_form(){
   my @html, @top, @bot ;

   $html[0] = "<form action=admin.cgi method=POST>
   <input type='hidden' name='mode' value='gen' />
   Please enter the correct password: 
   <input type='password' size='20' name='password' />
   <input type='submit' value='Log In' />
   </form>" ;

   #read top.html into memory
   open( TOP, "top.html" ) ;
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

   #read bot.html into memory
   open( BOT, "bot.html" ) ;
   $i = 0 ;
   while( $input = <BOT> ){
      $bot[$i] = $input ;
      $i++ ;
   }
   close( BOT ) ;
   
#finally print the html page back to the client
#append charset=UTF-8 so browsers will know to view multilingual pages as unicode and render properly
$type="text/html;charset=UTF-8" ;
&jcgi::print_header( "Content-type", $type ) ;

   #print page to browser
   print "@top @html @bot" ;

   exit ;

}
