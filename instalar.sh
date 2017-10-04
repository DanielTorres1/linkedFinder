#!/bin/bash
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
RESET='\e[0m'


function print_ascii_art {
cat << "EOF"
   
 LINKEDIN FINDER
                                                  

					daniel.torres@owasp.org
					https://github.com/DanielTorres1

EOF
}


print_ascii_art

echo -e "$OKBLUE [+] Instalando Google search $RESET" 
cd googlesearch
sudo cpanm .
cd ..

echo -e "$OKBLUE [+] Instalando linkedIN $RESET" 
cd linkedin
sudo cpanm .
cd ..

sudo cp linkedinFinder.pl /usr/bin/linkedinFinder.pl
sudo chmod a+x /usr/bin/linkedinFinder.pl


