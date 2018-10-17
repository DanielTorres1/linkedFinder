#module-starter --module=linkedin --author="Daniel Torres" --email=daniel.torres@owasp.org
# Aug 27 2012
# linkedin interface
package linkedin;
our $VERSION = '1.0';
use Moose;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Cookies;
use JSON qw( decode_json ); 
use URI::Escape;
use HTTP::Request;
use HTTP::Response;
use Net::SSL (); # From Crypt-SSLeay
use List::Util qw(shuffle);
use Time::HiRes qw(gettimeofday);
use MIME::Base64::Perl;
use POSIX;    
use HTML::Entities;


$Net::HTTPS::SSL_SOCKET_CLASS = "Net::SSL"; # Force use of Net::SSL for proxy compatibility

{
has 'mail', is => 'rw', isa => 'Str',default => '';	
has 'password', is => 'rw', isa => 'Str',default => '';	
has 'csrftoken', is => 'rw', isa => 'Str', default => '';	

has user_agent      => ( isa => 'Str', is => 'rw', default => '' );
has proxy_host      => ( isa => 'Str', is => 'rw', default => '' );
has proxy_port      => ( isa => 'Str', is => 'rw', default => '' );
has proxy_user      => ( isa => 'Str', is => 'rw', default => '' );
has proxy_pass      => ( isa => 'Str', is => 'rw', default => '' );
has proxy_env      => ( isa => 'Str', is => 'rw', default => '' );
has debug      => ( isa => 'Int', is => 'rw', default => 0 );
has headers  => ( isa => 'Object', is => 'rw', lazy => 1, builder => '_build_headers' );
has cookies  => ( isa => 'Object', is => 'rw', lazy => 1, builder => '_build_cookies' );
has browser  => ( isa => 'Object', is => 'rw', lazy => 1, builder => '_build_browser' );


# user info
##### site info #######       
sub login
{
my $self = shift;
my $headers = $self->headers;
my $debug = $self->debug;


my $login_url = "https://www.linkedin.com/";

my $mail = $self->mail;
my $password = $self->password;


my $tries=0;
GET1:
my $response = $self->dispatch(url => $login_url,method => 'GET',headers => $headers);
my $status = $response->status_line;
my $cookies = $self->cookies;

 if($status =~ /500|503|504|403/m){
	 return 0;
 }
 
#Set-Cookie: bcookie="v=2&7bb6f508-003c-46bf-81e9-55748a167a28"; 
my $content =$response->decoded_content;
my $raw = $response->as_string;

$raw =~ /bcookie="(.*?)"/;
my $csrftoken = $1; 

$csrftoken =~ s/v=2\&//g; 


print "login with $csrftoken \n" if ($debug);

if ($csrftoken eq '' )
{
  return 0;  
 }

sleep 2;
my $hash_data = {'session_key' => $mail, 
				'session_password' => $password, 
				'isJsEnabled' => 'false', 
				'loginCsrfParam' => $csrftoken, 
				};
	
	
my $post_data = convert_hash($hash_data);
		
$headers->header('Referer' => 'https://www.linkedin.com/login/');
$headers->header('Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
$headers->header('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8');

														
$response = $self->dispatch(url =>'https://www.linkedin.com/uas/login-submit',method => 'POST',post_data =>$post_data,headers => $headers);
my $status_login = $response->status_line;
my $response_headers = $response->headers_as_string;
print "response_headers with $response_headers \n" if ($debug);
print "status_login with $status_login \n" if ($debug);


$self->csrftoken($csrftoken);

 
if($status_login =~ /500|503|504|403|401/m)
 {return 0;}
else
 {return 1;}  
}



###################################### internal functions ###################
sub dispatch {    
my $self = shift;
my $debug = $self->debug;
my %options = @_;

my $url = $options{ url };
my $method = $options{ method };
my $headers = $options{ headers };
my $response;

if ($method eq 'POST_OLD')
  {     
   my $post_data = $options{ post_data };        
   $response = $self->browser->post($url,$post_data);
  }  
    
if ($method eq 'GET')
  { my $req = HTTP::Request->new(GET => $url, $headers);
    $response = $self->browser->request($req)
  }
  
if ($method eq 'POST')
  {     
   my $post_data = $options{ post_data };           
   my $req = HTTP::Request->new(POST => $url, $headers);
   $req->content($post_data);
   $response = $self->browser->request($req);    
  }  
  
if ($method eq 'POST_MULTIPART')
  {    	   
   my $post_data = $options{ post_data }; 
   $headers->header('Content_Type' => 'multipart/form-data');
    my $req = HTTP::Request->new(POST => $url, $headers);
   $req->content($post_data);
   #$response = $self->browser->post($url,Content_Type => 'multipart/form-data', Content => $post_data, $headers);
   $response = $self->browser->request($req);    
  } 

if ($method eq 'POST_FILE')
  { 
	my $post_data = $options{ post_data };         	    
	$headers->header('Content_Type' => 'application/atom+xml');
    my $req = HTTP::Request->new(POST => $url, $headers);
    $req->content($post_data);
    #$response = $self->browser->post( $url, Content_Type => 'application/atom+xml', Content => $post_data, $headers);                 
    $response = $self->browser->request($req);    
  }  
      
  
return $response;
}


sub remove_duplicates
{
 my $self = shift;		
my (@array) = @_; 

my %seen;
for ( my $i = 0; $i <= $#array ; )
{
    splice @array, --$i, 1
        if $seen{$array[$i++]}++;
}

return @array;
}

######
#Convert a hash in a string format used to send POST request
sub convert_hash
{
my ($hash_data)=@_;
my $post_data ='';
foreach my $key (keys %{ $hash_data }) {    
    my $value = $hash_data->{$key};
    $post_data = $post_data.uri_escape($key)."=".$value."&";    
}	
chop($post_data); # delete last character (&)
 #$post_data = uri_escape($post_data);
return $post_data;
}

################################### build objects ########################

################### build headers object #####################
sub _build_headers {   
my $self = shift;
my $debug = $self->debug;
print "building header \n" if ($debug);
my $headers = HTTP::Headers->new;

#my @user_agents=("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.71 Chrome/28.0.1500.71 Safari/537.36",
#			  "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.62 Safari/537.36",
			  #"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:23.0) Gecko/20100101 Firefox/23.0",
			  #"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.63 Safari/537.31",
			  #"Mozilla/5.0 (Windows NT 6.2; WOW64; rv:22.0) Gecko/20100101 Firefox/22.0",
			  #"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.62 Safari/537.36",
			  #"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",
			  #"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.36");
			  
$headers->header('User-Agent' => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.109 Safari/537.36"); 
$self->browser->default_header('User-Agent' => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.109 Safari/537.36");
$headers->header('Accept-Language' => 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3'); 
$headers->header('Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'); 
$headers->header('Upgrade-Insecure-Requests' => '1'); 
$headers->header('DNT' => '1'); 

$headers->header('Accept-Encoding' => [ HTTP::Message::decodable() ]);

return $headers; 
}

################### build browser object #####################	

sub _build_cookies { 
my $self = shift;
my $debug = $self->debug;
print "building cookie \n" if ($debug);
my $cookies = HTTP::Cookies->new();
return $cookies;	
}

sub _build_browser {    

my $self = shift;

my $debug = $self->debug;
my $proxy_host = $self->proxy_host;
my $proxy_port = $self->proxy_port;
my $proxy_user = $self->proxy_user;
my $proxy_pass = $self->proxy_pass;
my $proxy_env = $self->proxy_env;
my $cookies = $self->cookies;

print "building browser \n" if ($debug);

my $browser = LWP::UserAgent->new;

$browser->timeout(20);
$browser->cookie_jar($cookies);
$browser->show_progress(1) if ($debug);

print "proxy_env $proxy_env \n" if ($debug);

if ( $proxy_env eq 'ENV' )
{
print "set ENV PROXY \n" if ($debug);
$Net::HTTPS::SSL_SOCKET_CLASS = "Net::SSL"; # Force use of Net::SSL
$ENV{HTTPS_PROXY} = "http://".$proxy_host.":".$proxy_port;

}
elsif (($proxy_user ne "") && ($proxy_host ne ""))
{
 $browser->proxy(['http', 'https'], 'http://'.$proxy_user.':'.$proxy_pass.'@'.$proxy_host.':'.$proxy_port); # Using a private proxy
}
elsif ($proxy_host ne "")
   { $browser->proxy(['http', 'https'], 'http://'.$proxy_host.':'.$proxy_port);} # Using a public proxy
 else
   { 
      $browser->env_proxy;} # No proxy       

return $browser;     
}
    
}
1;
