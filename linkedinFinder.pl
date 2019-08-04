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
getopts('n:p:g:l:h', \%opts);

################ Config here ##################

my $mail = 'johnswyyf@hotmail.com';
my $password ='vdhgd543Hs';
my $profile= "https://www.linkedin.com/in/juan-perez-91a7b112a/";


#my $mail = 'dtorres@agetic.gob.bo';
#my $password ='BoliviaenTusManos';
#my $profile= "https://www.linkedin.com/in/juan-gonzales-722675172/";





################################################


my @profile_array = split /\//, $profile; #from URL to array
my $mypattern = @profile_array[4]; # juan-perez-91a7b112a
	  
	  
my $nombre = $opts{'n'} if $opts{'n'};
my $log_file = $opts{'l'} if $opts{'l'};
my $nogoogle = $opts{'g'} if $opts{'g'};

my $banner = <<EOF;

LINKED-FINDER                                                     

Autor: Daniel Torres Sandi
EOF


sub usage { 
  
  print $banner;
  print "Uso:  \n";  
  print "-e : Nombre de la empresa (Como aparece en LinkedIN) \n";  
  print "linkedFinder.pl -e [Mi empresa SRL]  -p 3 \n";  
  
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

if ($nogoogle ne 1)
{

	$term = "site:bo.linkedin.com -inurl:/jobs/ \"$nombre\" -intitle:mejores -intitle:perfiles";
	
	print BLUE,"\t[+] Estimando resultados .. \n",RESET;
	my $url = "http://www.google.com/search?output=search&sclient=psy-ab&q=$term&btnG=&gbv=1&filter=0&num=100";
	$response = $google_search->dispatch(url =>$url ,method => 'GET');
	my $content = $response->content;

	open (SALIDA,">>google.html") || die "ERROR: No puedo abrir el fichero $salida\n";
	print SALIDA $content,"\n" ;
	close (SALIDA);
	
	 #if (! ($content =~ /our systems have detected unusual traffic/m)){	 
		 #print "Captcha detected !!";
		#die;
	#}
			
	$noresult=`grep 'o se han encontrado resultados' google.html`;    
    if ($noresult eq "")
	{
		$total_pages=`grep -o 'start=' google.html | wc -l`; 
		#print "total_pages $total_pages \n";
		if ($total_pages == 0)
		   {$total_pages=1;}
	}
	else
	{print "No hay resultados en google para esa busqueda"; die;}
	
	system("rm google.html");
	
	


print YELLOW,"\t[+] Termino de busqueda: $term \n",RESET;
print YELLOW,"\t[+] Paginas a revisar: $total_pages \n",RESET;

print BLUE,"\t[+] Buscando en google \n",RESET;
		
for (my $page =0 ; $page<=$total_pages-1;$page++)		
{
		print "\t\t[+] pagina : $page \n";
		# Results 1-100
		#print "term $term \n";		
		$list = $google_search->search(keyword => $term, country => "bo", start => $page*100, log => "/dev/null");
		#print "list $list \n";
		my @list_array = split(";",$list);

		foreach $url (@list_array)
		{
			$url =~ s/\n//g; 
			open (SALIDA,">>url-list.csv") || die "ERROR: No puedo abrir el fichero report-$time.csv\n";
			print SALIDA $url,"\n" ;
			close (SALIDA);
		}	
		my $time_sleep = 30+($page*10);
		if ($time_sleep > 60)
			{
				my $random_number = int(rand(30));
				$time_sleep=60+$random_number;
			}
		print "\t\t[+] Durmiendo $time_sleep  segundos para evitar bloqueo de google \n";
		sleep $time_sleep ;
}		

#system("bash fix.sh");
}

print BLUE,"\t[+] Extrayendo datos de linked-in \n",RESET;		
  
#$linkedin->login;								
										
open (MYINPUT,"<url-list.csv") || die "ERROR: Can not open the file \n";
while ($url=<MYINPUT>)
{ 
  $url =~ s/\n//g; 	
  #$pattern = $url;
  #$pattern =~ s/https:\/\/bo.linkedin.com\/in\///g; 
  #print("pattern $pattern \n");
  #$existe=`grep -ia $pattern ALL.csv`;
  #print("$link");
 
  #if($existe ne ""){	 
#	$url = "";
	#print "\t\t[+] Ya recopilamos info de ese perfil \n";
  #}

  
 if($url =~ /dir|showcase|company|learning/m){	 
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
	  my $status = $response->status_line;
	  
	  
	  
	  #open (SALIDA,">>linkedin.html") || die "ERROR: No puedo abrir el fichero google.html\n";				
#		print SALIDA "$response_1\n";
		#close (SALIDA);
		
		
	  print("status $status\n");
	  # if($status =~ /Assumed/m){	 
		   #die;
	   #}
 
 	  
	  
	  $response_1 =~ s/&quot;/"/g; 
	  $response_1 =~ s/&amp;/&/g; 
	  $response_1 =~ s/&#92;"/'/g;
	  $response_1 =~ s/&#92;t//g;
	  #my $random_number = 30 + int(rand(30));
	  #sleep $random_number;
	  	  
	  #$response_1 =~ s/^.*?$mypattern//s;  #delete everything before juan-perez-91a7b112a
        

	 #while($response_1 =~ /"firstName":"(.*?)"/g) 
	 #{
       #$firstName = $1; 
      #}
      
      
	 #"name":"Marisol Catari"  
	 $response_1 =~ /"name":"(.*?)"/;
	 my $nombre = $1; 

	#data-section="headline">Adm. de Base de Datos en Banco Central de Bolivia</
	 $response_1 =~ /data-section="headline">(.*?)</;
	 my $headline = $1; 
 
	#"position__company-name">Ministerio de Desarrollo Productivo y Economía Plural</
	$response_1 =~ /"position__company-name">(.*?)</;
	 my $company = $1; 
	 $company =~ s/-/ /g;
	 $headline =~ s/-/ /g;
 
      
      
#      while($response_1 =~ /"lastName":"(.*?)"/g) 
	 #{
       #$lastName = $1; 
      #}
	  	 
	if ($nombre eq '')
	{				
		if ($counter < 1)	
		{			
			$counter++;
			goto REPEAT;
		}
		
		open (SALIDA,">$headline.html") || die "ERROR: No puedo abrir el fichero google.html\n";
		print SALIDA $response_1;
		close (SALIDA);
		print RED,"\t\t[+] Upps $url \n",RESET;	
	}
	  
	  print "\t\t[+] Extrayendo datos del perfil $url \n";	  
	  print "\t\t\t[i] Nombre : $nombre \n";	  ;	  
	  print "\t\t\t[i] headline  $headline\n";
	  print "\t\t\t[i] Compañia  $company\n\n";
	  
	  
	  if ($headline ne "")
	  {	  
		open (SALIDA,">>$log_file") || die "ERROR: No puedo abrir el fichero google.html\n";		
		my $output = only_ascii("$nombre;$headline;$company");		
		print SALIDA "$output\n";
		close (SALIDA);
	   }
  } # if no url


}
close MYINPUT;

system("rm url-list.csv");	

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
