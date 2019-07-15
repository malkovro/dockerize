#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p port -n container_name -d directory"
   echo -e "\t-p Port to use on the host to redirect to 80 inside"
   echo -e "\t-n Name of the container/the app"
   echo -e "\t-d Path of the directory (default to where the script is launched)"
   exit 1 # Exit script after printing help
}

directory=/${PWD}/

while getopts "p:n:d:" opt
do
   case "$opt" in
      p ) port="$OPTARG" ;;
      n ) name="$OPTARG" ;;
      d ) directory="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$port" ] || [ -z "$name" ] || [ -z "$directory" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "About to create a php:apache container with: \n \t\tname ${GREEN}${name}${NC}  \n \t\tHttp port forwarded to port: ${GREEN}${port}${NC}  \n \t\tBased on project found in ${GREEN}${directory}${NC}\n"
read -p "Are you sure?(Y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    printf "docker create --name $name -p $port:80 -v $directory:/var/www/html php:apache"
    docker create --name $name -p $port:80 -v "$directory":/var/www/html php:apache
    docker start $name
    docker exec -d $name docker-php-ext-install pdo pdo_mysql
    docker exec -it $name a2enmod rewrite
    docker restart $name 

    echo "Running composer install"
    docker run --rm -it -v $directory:/app composer install --ignore-platform-reqs

    echo "Starting container"
    docker start $name

fi

