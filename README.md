
# linkedFinder

Buscador de perfiles de Linkedin (bo.linkedin.com) de una determinada empresa, utiliza google dorks para determinar la lista de empleados que tienen su perfil de Linkedin para luego extraer sus datos personales y almacenarlos en un archivo csv.


## ¿COMO INSTALAR?

Testeado en Kali 2:

    git clone https://github.com/DanielTorres1/linkedinFinder
    cd linkedinFinder
    bash instalar.sh


## ¿COMO USAR?
**linkedFinder.pl**

    Opciones:
    -e : Nombre de la empresa (Como aparece en LinkedIN) 
    -p : Número de paginas de google a revisar 
    -k : UNA SOLA palabra clave para filtrar la salida (Ej: sigla o nombre de la empresa ). Esta palabra clave es usada para eliminar falsos positivos. 

Ej: Buscar perfiles de la empresa "Hewlett Packard Enterprise" en las 3 primeras páginas de google.

linkedinFinder.pl -e "Hewlett Packard Enterprise " -p 5 -k Hewlett

