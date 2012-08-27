#!/usr/bin/perl
#
# language.pm, a perl module used to store CGI Calendar text in different
# languages.
# By Jay Eckles 
# Copyright 2005 Jay Eckles
# This file is licensed under the GPL version 2 and is provided without warranty.  
# See http://www.gnu.org/copyleft/gpl.html for license details.
#
#
# Created on 3/27/2005
# $Id: language.pm,v 1.11 2005/04/23 15:58:54 ecklesweb Exp $
#

use utf8;

### Don't touch these next five lines!
package language ;
require Exporter ;
@ISA = qw( Exporter ) ;
@EXPORT = qw( loadText ) ;
@EXPORT_OK = qw(%text,@monthnames,@day,$govalue,$prevgifalt,$nextgifalt) ;
### Don't touch the previous five lines!

sub loadText{
   
   my $lang = shift() ;
   
#English and German translations by Jay Eckles
   $availableLanguages{"en-us"} = "US English" ;
   $availableLanguages{"de"} = "Deutsch" ;
   
#Esperanto, Portuguese, Japanese, Russian, Hungarian, Dutch, and Spanish translations by 
#the TRADUKADO GROUP, a community of Esperantist translators
#Thanks to Igor de Oliveira Couto for garnering assistance from TRADUKADO GROUP.
   $availableLanguages{"eo"} = "Esperanto" ;
   $availableLanguages{"pt-br"} = "Português do Brasil" ;
   $availableLanguages{"jp"} = "日本語" ;
   $availableLanguages{"ru"} = "русский" ;
   $availableLanguages{"hu"} = "Magyar" ;
   $availableLanguages{"da"} = "Dansk" ;
   $availableLanguages{"es"} = "Español" ;   
   
#French translation by Catherine Beauchemin, cbeau@users.sourceforge.net
   $availableLanguages{"fr"} = "Français" ;
   
#Polish translation by Ewa Wojtowicz, f_cia@users.sourceforge.net
   $availableLanguages{"pl"} = "Polski" ;  
   
#Greek translation by "Katie" (anonymous submission)
   $availableLanguages{"el"} = "Ελληνικά" ;  
   
   
   if( $lang eq "en-us" ){
#US English - set $value{"defaultLanguage"} = "en-us" in jconfig.pm to use US English as default.
         
         @monthnames = ("January","February","March","April","May","June","July","August","September","October","November","December") ;
         
      @day = ("Sunday","Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ) ;
         
         $govalue = "Go" ;
         
         $prevgifalt = "Previous Month" ;
         $nextgifalt = "Next Month" ;
         $addgifalt = "Add Event" ;
         $deletegifalt = "Delete Event" ;
         $editgifalt = "Edit Event" ;
         
         $return = "Return to the Calendar" ;
         
         $what = "What" ;
         $when = "When" ;
         $where = "Where" ;
         $details = "Additional Details" ;
         
         $noevents = "No events are scheduled for today." ;
         
         $formdate = "Date" ;
         $formwhat = "What (no html)" ;
         $formwhen = "When" ;
         $formwhere = "Where (html ok)" ;
         $formdetails = "Additional Details <br>(html ok)" ;
         
         $addvalue = "Add Event" ;
         $editvalue = "Edit Event" ;
         $cancelvalue = "Cancel" ;
         
         $am = "AM" ;
         $pm = "PM" ;
         
         $addtitle = "Add an Event" ;
         $edittitle = "Edit an Event" ;
   }
   
   elsif( $lang eq "pt-br" ){
#Brazillian Portuguese - set $value{"defaultLanguage"} = "pt-br" in jconfig.pm to use Brazillian Portuguese as #default.
         
         @monthnames = ("Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro") ;
         
         @day = ("Domingo","Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado" ) ;
         
         $govalue = "Ir" ;
         
         $prevgifalt = "Mês Anterior" ;
         $nextgifalt = "Mês Seguinte" ;
         $addgifalt = "Entrar Novo Evento" ;
         $deletegifalt = "Deletar Evento" ;
         $editgifalt = "Editar Evento" ;
         
         $return = "Retornar ao Calendário" ;
         
         $what = "O Que" ;
         $when = "Quando" ;
         $where = "Onde" ;
         $details = "Detalhes Adicionais" ;
         
         $noevents = "Não há eventos marcados para hoje." ;
         
         $formdate = "Data" ;
         $formwhat = "O Que (sem html)" ;
         $formwhen = "Quando" ;
         $formwhere = "Onde (html ok)" ;
         $formdetails = "Detalhes Adicionais <br>(html ok)" ;
         
         $addvalue = "Entrar Novo Evento" ;
         $editvalue = "Editar Evento" ;
         $cancelvalue = "Cancelar" ;
         
         $am = "am" ;
         $pm = "pm" ;
         
         $addtitle = "Entrar Novo Evento" ;
         $edittitle = "Editar Evento" ;
   }
   
   elsif( $lang eq "de" ){
#German - set $value{"defaultLanguage"} = "de" in jconfig.pm to use German as default.
         
         @monthnames = ("Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember") ;
         
         @day = ("Sonntag","Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag" ) ;
         
         $govalue = "Gehen" ;
         
         $prevgifalt = "Vormonat" ;
         $nextgifalt = "Nächsten Monat" ;
         $addgifalt = "Addieren Fall" ;
         $deletegifalt = "Löschen Fall" ;
         $editgifalt = "Redigieren Fall" ;
         
         $return = "Gehen Sie zum Kalender zurück";
         
         $what = "Was" ;
         $when = "Wenn" ;
         $where = "Wo" ;
         $details = "zusätzliche Besonderen" ;
         
         $noevents = "Keine Fälle werden für heute festgelegt" ;
         
         $formdate = "Datum" ;
         $formwhat = "Was (keine html)" ;
         $formwhen = "Wenn" ;
         $formwhere = "Wo (html ok)" ;
         $formdetails = "$details (html ok)" ;
         
         $addvalue = $addgifalt ;
         $editvalue = $editgifalt ;
         $cancelvalue = "Löschen";
         
         $am = "AM" ;
         $pm = "PM" ;
         
         $addtitle = "Addieren Sie einen Fall" ;
         $edittitle = "Redigieren Sie einen Fall" ;
   }
   elsif( $lang eq "fr" ){
#French - set $value{"defaultLanguage"} = "fr" in jconfig.pm to use French as default.
         
         @monthnames =  ("Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Decembre") ;
         
         @day = ("Dimanche","Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi" ) ;
         
         $govalue = "Procéder" ;
         
         $prevgifalt = "Mois précédent" ;
         $nextgifalt = "Mois suivant" ;
         $addgifalt = "Ajouter un événement" ;
         $deletegifalt = "Effacer un événement" ;
         $editgifalt = "Modifier un événement" ;
         
         $return = "Retourner au Calendrier" ;
         
         $what = "Quoi" ;
         $when = "Quand" ;
         $where = "Où" ;
         $details = "Détails additionels" ;
         
         $noevents = "Aucun événement prévu pour aujourd'hui." ;
         
         $formdate = "Date" ;
         $formwhat = "Quoi (pas html)" ;
         $formwhen = "Quand" ;
         $formwhere = "Où (html ok)" ;
         $formdetails = "Détails additionnels <br>(html ok)" ;
         
         $addvalue = "Ajouter un événement" ;
         $editvalue = "Modifier un événement" ;
         $cancelvalue = "Annuler" ;
         
         $am = "am" ;
         $pm = "pm" ;
         
         $addtitle = "Ajouter un événement" ;
         $edittitle = "Modifier un événement" ;
   }
   elsif( $lang eq "jp" ){
#Japanese
      
      @monthnames = ("1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月") ;
      
      @day = ("日曜","月曜", "火曜", "水曜", "木曜", "金曜", "土曜" ) ;
      
      $govalue = "実行" ;
      
      $prevgifalt = "先月" ;
      $nextgifalt = "翌月" ;
      $addgifalt = "行事を追加" ;
      $deletegifalt = "行事を削除" ;
      $editgifalt = "行事を編集" ;
      
      $return = "カレンダーに戻る." ;
      
      $what = "何が" ;
      $when = "いつ" ;
      $where = "どこで" ;
      $details = "詳細" ;
      
      $noevents = "今日の行事なし." ;
      
      $formdate = "日付" ;
      $formwhat = "何が(html 不可)" ;
      $formwhen = "いつ" ;
      $formwhere = "どこで (html 可)" ;
      $formdetails = "詳細 <br>(html 可)" ;
      
      $addvalue = "行事を追加" ;
      $editvalue = "行事を編集" ;
      $cancelvalue = "取消し" ;
      
      $am = "午前" ;
      $pm = "午後" ;
      
      $addtitle = "行事を追加" ;
      $edittitle = "行事を編集" ;
   }
   elsif( $lang eq "es" ){
#Spanish
      
      @monthnames = ("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Setiembre","Octubre","Noviembre","Diciembre") ;
      
      @day = ("Domingo","Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado" ) ;
      
      $govalue = "Adelante" ;
      
      $prevgifalt = "Mes anterior" ;
      $nextgifalt = "Mes siguiente" ;
      $addgifalt = "Añadir evento" ;
      $deletegifalt = "Borrar evento" ;
      $editgifalt = "Editar evento" ;
      
      $return = "Volver al calendario." ;
      
      $what = "Qué" ;
      $when = "Cuándo" ;
      $where = "Dónde" ;
      $details = "Más Detalles (html)" ;
      
      $noevents = "No hay eventos para hoy." ;
      
      $formdate = "Fecha" ;
      $formwhat = "Qué (no html)" ;
      $formwhen = "Cuándo" ;
      $formwhere = "Dónde (html)" ;
      $formdetails = "Más Detalles <br>(html)" ;
      
      $addvalue = "Añadir evento" ;
      $editvalue = "Editar evento" ;
      $cancelvalue = "Cancelar" ;
      
      $am = "AM" ;
      $pm = "PM" ;
      
      $addtitle = "Añadir evento" ;
      $edittitle = "Editar evento" ;
   }
   
   elsif( $lang eq "da" ){
#Danish
      
      @monthnames = ("Januar", "Februar", "Marts", "April", "Maj", "Juni", "Juli", "August", "September", "Oktober", "November", "December") ;
      
      @day = ("Søndag", "Mandag", "Tirsdag", "Onsdag", "Torsdag", "Fredag", "Lørdag" ) ;
      
      $govalue = "Gå" ;
      
      $prevgifalt = "Forrige måned" ;
      $nextgifalt = "Næste måned" ;
      $addgifalt = "Tilføj Begivenhed" ;
      $deletegifalt = "Slet Begivenhed" ;
      $editgifalt = "Rediger Begivenhed" ;
      
      $return = "Tilbage til Kalenderen" ;
      
      $what = "Hvad" ;
      $when = "Hvornår" ;
      $where = "Hvor" ;
      $details = "Yderligere Detaljer" ;
      
      $noevents = "Ingen begivenheder er planlagt for idag." ;
      
      $formdate = "Dato" ;
      $formwhat = "Hvad (ingen html)" ;
      $formwhen = "Hvornår" ;
      $formwhere = "Hvor (html ok)" ;
      $formdetails = "Yderligere Detaljer <br>(html ok)" ;
      
      $addvalue = "Tilføj Begivenhed" ;
      $editvalue = "Rediger Begivenhed" ;
      $cancelvalue = "Slet" ;
      
      $am = "om morgenen" ;
      $pm = "om aftenen" ;
      
      $addtitle = "Tilføj en Begivenhed" ;
      $edittitle = "Rediger en Begivenhed" ;
   }
   
   elsif( $lang eq "hu" ){
#Hungarian
      
      @monthnames = ("január","február","március","április","május","junius","július","augusztus","szeptember","október","november","december") ;
      
      @day = ("vasárnap","hétfo˝", "kedd", "szerda", "csütörtök", "péntek", "szombat" ) ;
      
      $govalue = "Mehet" ;
      
      $prevgifalt = "előző hónap" ;
      $nextgifalt = "következo˝ hónap" ;
      $addgifalt = "Esemény hozzáadása" ;
      $deletegifalt = "Esemény törlése" ;
      $editgifalt = "Esemény szerkesztése" ;
      
      $return = "Vissza a naptárhoz." ;
      
      $what = "megnevezés" ;
      $when = "mikor" ;
      $where = "hol" ;
      $details = "egyéb részletek" ;
      
      $noevents = "Nincs mára elo˝jegyzett esemény." ;
      
      $formdate = "dátum" ;
      $formwhat = "megnevezés (ne használj html-t)" ;
      $formwhen = "mikor" ;
      $formwhere = "hol (használhatsz html-t)" ;
      $formdetails = "egyéb részletek <br>(használhatsz html-t)" ;
      
      $addvalue = "Esemény hozzáadása" ;
      $editvalue = "Esemény szerkesztése" ;
      $cancelvalue = "Mégsem" ;
      
      $am = "de" ;
      $pm = "du" ;
      
      $addtitle = "Esemény hozzáadása" ;
      $edittitle = "Esemény szerkesztése" ;
   }
   
   elsif( $lang eq "ru" ){
#Russian
      
      @monthnames = ("январь","февраль","март","апрель","май","июнь","июль","август","сентябрь","октябрь","ноябрь","декабрь") ;
      
      @day = ("воскресенье","понедельник", "вторник", "среда", "четверг", "пятница", "суббота" ) ;
      
      $govalue = "выполнить" ;
      
      $prevgifalt = "предыдущий месяц" ;
      $nextgifalt = "следующий месяц" ;
      $addgifalt = "добавить событие" ;
      $deletegifalt = "удалить событие" ;
      $editgifalt = "редактировать событие" ;
      
      $return = "вернуться в календарь" ;
      
      $what = "что" ;
      $when = "когда" ;
      $where = "где" ;
      $details = "подробнее" ;
      
      $noevents = "сегодня событий нет" ;
      
      $formdate = "дата" ;
      $formwhat = "что (без html)" ;
      $formwhen = "когда" ;
      $formwhere = "где (с html)" ;
      $formdetails = "подробнее <br>(с html)" ;
      
      $addvalue = "добавить событие" ;
      $editvalue = "редактировать событие" ;
      $cancelvalue = "отмена" ;
      
#NOTE: Russians *always* use a 24-hour clock, so there is really no  official translation of "am" and "pm"!
#$am = "до полудня" ;
#$pm = "после полудня" ;
         $am = "AM" ;
      $pm = "PM" ;
      
      $addtitle = "добавить событие" ;
      $edittitle = "редактировать событие" ;
   }
   
   
   elsif( $lang eq "eo" ){
#Esperanto
      @monthnames = ("Januaro","Februaro","Marto","Aprilo","Majo","Junio","Julio","Aŭgusto","Septembro","Oktobro","Novembro","Decembro") ;
      
      @day = ("Dimanĉo","Lundo", "Mardo", "Merkredo", "Jaŭdo", "Vendredo", "Sabato" ) ;
      
      $govalue = "Ek" ;
      
      $prevgifalt = "Antaŭa Monato" ;
      $nextgifalt = "Sekva Monato" ;
      $addgifalt = "Aldoni Eventon" ;
      $deletegifalt = "Forigi Eventon" ;
      $editgifalt = "Redakti Eventon" ;
      
      $return = "Reiri la Kalendaron" ;
      
      $what = "Kio" ;
      $when = "Kiam" ;
      $where = "Kie" ;
      $details = "Pliaj Detaloj" ;
      
      $noevents = "Neniu evento hodiaŭ." ;
      
      $formdate = "Dato" ;
      $formwhat = "Kio (html ne eblas)" ;
      $formwhen = "Kiam" ;
      $formwhere = "Kie (html eblas)" ;
      $formdetails = "Pliaj Detaloj <br>(html eblas)" ;
      
      $addvalue = "Aldoni Eventon" ;
      $editvalue = "Redakti Eventon" ;
      $cancelvalue = "Rezigni" ;
      
      $am = "atm" ;
      $pm = "ptm" ;
      
      $addtitle = "Aldoni Eventon" ;
      $edittitle = "Redakti Eventon" ;
   }
   
   
   elsif( $lang eq "pl" ){
#Polish
      
      @monthnames = ("Styczeń","Luty","Marzec","Kwiecień","Maj","Czerwiec","Lipiec","Sierpień","Wrzesień","Październik","Listopad","Grudzień") ;
      
      @day = ("Niedziela","Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota" ) ;
      
      $govalue = "Skocz" ;
      
      $prevgifalt = "Poprzdni miesiąc" ;
      $nextgifalt = "Następny miesiąc" ;
      $addgifalt = "Dodaj wpis" ;
      $deletegifalt = "Usuń wpis" ;
      $editgifalt = "Edytuj wpis" ;
      
      $return = "Wróć do kalendarza" ;
      
      $what = "Co" ;
      $when = "Kiedy" ;
      $where = "Gdzie" ;
   $details = "Szczegóły" ;

   $noevents = "Na dziś nie zostały zaplanowane żadne zadania." ;

   $formdate = "Data" ;
   $formwhat = "Co (bez html-a)" ;
   $formwhen = "Kiedy" ;
   $formwhere = "Gdzie (html dozwolony)" ;
   $formdetails = "Szczegóły <br>(html dozwolony)" ;

   $addvalue = "Dodaj wpis" ;
   $editvalue = "Usuń wpis" ;
   $cancelvalue = "Anuluj" ;
   
   $am = "AM" ;
   $pm = "PM" ;

   $addtitle = "Dodaj wpis" ;
   $edittitle = "Usuń wpis" ;
}

elsif( $lang eq "el" ){
#Greek - set $value{"defaultLanguage"} = "el" in jconfig.pm to use Greek as default.
          
   @monthnames = ( "Ιανουάριος", "Φεβρουάριος", "Μάρτιος", "Απρίλιος", "Μάιος", "Ιούνιος", "Ιούλιος", "Αύγουστος", "Σεπτέμβριος", "Οκτώβριος", "Νοέμβριος", "Δεκέμβριος" ) ;
          
   @day = ( "Κυριακή", "Δευτέρα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευή", "Σάββατο" ) ;
          
   $govalue = "Πάμε";
          
   $prevgifalt = "Προηγούμενος Μήνας" ;
   $nextgifalt = "Επόμενος Μήνας" ;
   $addgifalt = "Προσθήκη Γεγονότος" ;
   $deletegifalt = "Διαγραφή Γεγονότος" ;
   $editgifalt = "Επεξεργασία Γεγονότος" ;
          
   $return = "Επιστροφή στο Ημερολόγιο" ;
         
   $what = "Τι" ;
   $when = "Πότε" ;
   $where = "Πού" ;
   $details = "Περισσότερες Λεπτομέρειες" ;
          
   $noevents = "Δεν υπάρχουν προγραμματισμένα γεγονότα για σήμερα." ;
          
   $formdate = "Ημ/νία" ;
   $formwhat = "Τι (χωρίς html)" ;
   $formwhen = "Πότε" ;
   $formwhere = "Πού (επιτρέπεται html)" ;
   $formdetails = "Περισσότερες Λεπτομέρειες <br>(επιτρέπεται html)" ;
          
   $addvalue = "Προσθήκη Γεγονότος" ;
   $editvalue = "Επεξεργασία Γεγονότος" ;
   $cancelvalue = "Ακύρωση" ;
          
   $am = "πμ" ;
   $pm = "μμ" ;
          
   $addtitle = "Προσθήκη Γεγονότος" ;
   $edittitle = "Επεξεργασία Γεγονότος" ;
}
else{
   &loadText( "en-us" ) ;
}

}
