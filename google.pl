#!/usr/bin/perl
use googlesearch;
use Data::Dumper;
use Getopt::Std;
use Term::ANSIColor qw(:constants);
use utf8;
use Text::Unidecode;
binmode STDOUT, ":encoding(UTF-8)";
my %opts;
getopts('p:k:h', \%opts);

	  
my $pages = $opts{'p'} if $opts{'p'};
my $keyword = $opts{'k'} if $opts{'k'};

my $banner = <<EOF;


Autor: Daniel Torres Sandi
EOF


sub usage { 
  
  print $banner;
  print "Uso:  \n";  
    print "-p : Paginas de google a revisar \n";
  print "-k : keyword \n";
  print "perl google.pl -k \"inurl:robot\"  -p 3 \n";  
  
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

print YELLOW,"\t[+] Termino de busqueda: $keyword \n",RESET;
print YELLOW,"\t[+] Paginas a revisar: $pages \n",RESET;

print BLUE,"\t[+] Buscando en google \n",RESET;
		
for (my $page =0 ; $page<=$pages-1;$page++)		
{
		print "\t\t[+] pagina: $page \n";
		# Results 10-20 
		$list = $google_search->search(keyword => $keyword, country => "", start => $page*10);
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
			
