#!/user/local/bin/perl

#$Apache::Registry::Debug++;
require Devel::Symdump;
require Apache::CGI;
use File::CounterFile;

my $q = new Apache::CGI;

#$Laststash ||= Devel::Symdump->rnew();

$q->print(
   $q->header,	
   $q->start_html(),	  
   "Can you tell if I've been run under CGI or Apache::Registry?<p>",
   $q->start_form(),
   $q->textfield(-name => "textfield"),
   $q->submit(),
   $q->end_form,
   "<p>textfield = ", $q->param("textfield"),
		"<PRE>",
	  "Running in Process <B>$$</B>\n",

);

#$Currentstash = Devel::Symdump->rnew();
my $c = File::CounterFile->new("COUNTER2","00000000");
my $id = $c->inc;

$q->print(
	  "<H4>", scalar(localtime()),"</H4>",
#	  $Laststash->diff($Currentstash),
#	  "<PRE>",
#	  $q->dump,
	  sprintf("Accessed %d times",$id),
	  $q->end_html,
	 );

#$Laststash = $Currentstash;


# $q->print(Apache::Debug::dump($q, 404));
