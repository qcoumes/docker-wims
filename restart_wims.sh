docker container rm wims -f
docker run -itd --cpuset-cpus=$(($(cat /proc/cpuinfo | grep -e "processor\s*:\s*\d*" | wc -l) - 1)) -p 7777:80 --name wims wims
docker exec -it wims ./bin/apache-config
docker exec -it wims service apache2 restart
