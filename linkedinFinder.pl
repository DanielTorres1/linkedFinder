#!/usr/bin/perl
use googlesearch;
use linkedin;
use Data::Dumper;
use Getopt::Std;
use Term::ANSIColor qw(:constants);

my %opts;
getopts('e:p:k:h', \%opts);

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

my $linkedin = linkedin->new( mail => 'johnswyyf@hotmail.com',					
					password => 'vdhgd543Hs', 					
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
		print "\t\t[+] Durmiendo 30 segundos para evitar bloqueo de google \n";
		sleep 30;
}		
			

print BLUE,"\t[+] Extrayendo datos de linked-in \n",RESET;		
  
$linkedin->login;								
										
open (MYINPUT,"<url-list.csv") || die "ERROR: Can not open the file \n";
while ($url=<MYINPUT>)
{ 
  $url =~ s/\n//g; 	
  if ( $url ne "")
  {
	  my $occupation;
	  my $lastName;
	  my $firstName;

	  $url =~ s/bo\./www\./g; 	
	  $url = $url."/?ppe=1";
	  
	  my $response = $linkedin->dispatch(url =>$url,method => 'GET');	  
	  my $response_1 = $response->decoded_content;	  	 
	  $response_1 =~ s/&quot;/"/g; 	
	  
	  open (SALIDA,">linked.html") || die "ERROR: No puedo abrir el fichero google.html\n";
	print SALIDA $response_1;
	close (SALIDA);
	  
	  
	  while($response_1 =~ /"occupation":"(.*?)"/g) 
	 {
       $occupation = $1; 
      }

	 while($response_1 =~ /"firstName":"(.*?)"/g) 
	 {
       $firstName = $1; 
      }
      
      while($response_1 =~ /"lastName":"(.*?)"/g) 
	 {
       $lastName = $1; 
      }
	  	 


	  print "\t\t[+] Extrayendo datos del perfil $url \n";	  
	  print "\t\t\t[i] occupation $occupation \n";
	  print "\t\t\t[i] Name : $firstName $lastName \n";	  ;
	  #"occupation":"Geretne General en Cooperativa  Catedral de Tarija Ltda."
	  
	  if ($occupation ne "")
	  {	  
		open (SALIDA,">>linked.csv") || die "ERROR: No puedo abrir el fichero google.html\n";
		print SALIDA "$firstName;$lastName;$occupation\n";
		close (SALIDA);
	   }
  }


}
close MYINPUT;


system("grep -ai $key linked.csv > linkedin_$key.csv");
system("rm linked.csv; rm url-list.csv");
