#!/usr/bin/perl
use googlesearch;
use linkedin;
use Data::Dumper;
use Getopt::Std;
use Term::ANSIColor qw(:constants);
use utf8;
use Text::Unidecode;
binmode STDOUT, ":encoding(UTF-8)";
my %opts;
getopts('e:p:k:h', \%opts);

################ Config here ##################

my $mail = 'johnswyyf@hotmail.com';
my $password ='vdhgd543Hs';
my $profile= "https://www.linkedin.com/in/juan-perez-91a7b112a/";
################################################


my @profile_array = split /\//, $profile; #from URL to array
my $mypattern = @profile_array[4]; # juan-perez-91a7b112a
	  
	  
my $enterprise = $opts{'e'} if $opts{'e'};
my $pages = $opts{'p'} if $opts{'p'};
my $key = $opts{'k'} if $opts{'k'};

my $banner = <<EOF;


Autor: Daniel Torres Sandi
EOF


sub usage { 
  
  print $banner;
  print "Uso:  \n";  
  print "-e : Nombre de la empresa (Como aparece en LinkedIN) \n";
  print "-p : Paginas de google a revisar \n";
  print "-k : UNA palabra clave para filtrar la salida (sigla o nombre de la empresa ) \n";
  print "perl linkedFinder.pl -e [Mi empresa SRL]  -p 3 -k empresa \n";  
  
}	

# Print help message if required
if ($opts{'h'} || !(%opts)) {
	usage();
	exit 0;
}




$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; #proxy compatibility
use Time::localtime;

my $t = localtime;
$time = sprintf( "%04d-%02d-%02d",$t->year + 1900, $t->mon + 1, $t->mday);


my $google_search = googlesearch->new();

my $linkedin = linkedin->new( mail => $mail,					
					password => $password, 					
					debug => 0, 
					proxy_host => '',
					proxy_port => '',
					proxy_user => '',
					proxy_pass => '');

$term = "site:bo.linkedin.com -inurl:/jobs/ \"$enterprise\" -intitle:mejores";

print YELLOW,"\t[+] Termino de busqueda: $term \n",RESET;
print YELLOW,"\t[+] Paginas a revisar: $pages \n",RESET;
print YELLOW,"\t[+] Filtrar resultados por: $key \n",RESET;

print BLUE,"\t[+] Buscando en google \n",RESET;
		
for (my $page =0 ; $page<=$pages-1;$page++)		
{
		print "\t\t[+] pagina: $page \n";
		# Results 10-20 
		$list = $google_search->search(keyword => $term, country => "bo", start => $page*10);
		my @list_array = split(";",$list);

		foreach $url (@list_array)
		{
			$url =~ s/\n//g; 
			open (SALIDA,">>url-list.csv") || die "ERROR: No puedo abrir el fichero report-$time.csv\n";
			print SALIDA $url,"\n" ;
			close (SALIDA);
		}	
		my $time_sleep = 30+($page*10);
		print "\t\t[+] Durmiendo $time_sleep  segundos para evitar bloqueo de google \n";
		sleep $time_sleep ;
}		
			

print BLUE,"\t[+] Extrayendo datos de linked-in \n",RESET;		
  
$linkedin->login;								
										
open (MYINPUT,"<url-list.csv") || die "ERROR: Can not open the file \n";
while ($url=<MYINPUT>)
{ 
  $url =~ s/\n//g; 	
  
 if($url =~ /dir/m){	 
	 $url = "";
	 print "\t\t[+] La URL es solo un listado de perfiles \n";
 }
 
  
  if ( $url ne "")
  {
	  my $occupation;
	  my $companyName;
	  my $lastName;
	  my $firstName;

	  $url =~ s/bo\./www\./g; 	
	  $url = $url."/?ppe=1";
	  my $counter=0;
	  REPEAT:
	  my $response = $linkedin->dispatch(url =>$url,method => 'GET');	  
	  my $response_1 = $response->decoded_content;	  	 
	  $response_1 =~ s/&quot;/"/g; 
	  $response_1 =~ s/&#92;"/'/g; 	 
	  	  	 
	  	  
	  $response_1 =~ s/^.*?$mypattern//s;  #delete everything before juan-perez-91a7b112a
  
	  while($response_1 =~ /"occupation":"(.*?)"/g) 
	 {
       $occupation = $1; 
      }
      
       my ($companyName) = ($response_1 =~ /"companyName":"(.*?)"/g);
       	 
      
       while($response_1 =~ /"headline":"(.*?)"/g) 
	 {
       $headline = $1; 
      }           

	 while($response_1 =~ /"firstName":"(.*?)"/g) 
	 {
       $firstName = $1; 
      }
      
      while($response_1 =~ /"lastName":"(.*?)"/g) 
	 {
       $lastName = $1; 
      }
	  	 
	if ($firstName eq '')
	{				
		if ($counter < 2)	
		{
			open (SALIDA,">$headline.html") || die "ERROR: No puedo abrir el fichero google.html\n";
			print SALIDA $response_1;
			close (SALIDA);
			print RED,"\t\t[+] Upps $url \n",RESET;		
			$counter++;
			goto REPEAT;
		}
	}


	  
	  
	  print "\t\t[+] Extrayendo datos del perfil $url \n";	  
	  print "\t\t\t[i] Name : $firstName $lastName \n";	  ;
	  print "\t\t\t[i] occupation $occupation \n";
	  print "\t\t\t[i] companyName  $companyName\n";
	  print "\t\t\t[i] headline  $headline\n\n";
	  
	  #"occupation":"Geretne General en Cooperativa  Catedral de Tarija Ltda."
	  
	  if ($occupation ne "")
	  {	  
		open (SALIDA,">>linked.csv") || die "ERROR: No puedo abrir el fichero google.html\n";		
		my $output = only_ascii("$firstName;$lastName;$occupation;$companyName;$headline;$url");		
		print SALIDA "$output\n";
		close (SALIDA);
	   }
  }


}
close MYINPUT;


system("grep --color=never -ai $key linked.csv > linkedin_$key.csv");
#system("rm linked.csv; rm url-list.csv");
system("rm google1.html; rm google2.html");

sub only_ascii
{
 my ($text) = @_;
 
$text =~ s/á/a/g; 
$text =~ s/é/e/g; 
$text =~ s/í/i/g; 
$text =~ s/ó/o/g; 
$text =~ s/ú/u/g;
$text =~ s/ñ/n/g; 

$text =~ s/Á/A/g; 
$text =~ s/É/E/g; 
$text =~ s/Í/I/g; 
$text =~ s/Ó/O/g; 
$text =~ s/Ú/U/g;
$text =~ s/Ñ/N/g;

return $text;
}
