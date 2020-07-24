docker container rm wims-minimal -f
docker run -itd --cpuset-cpus=$(($(cat /proc/cpuinfo | grep -e "processor\s*:\s*\d*" | wc -l) - 1)) -p 7777:80 --name wims-minimal wims-minimal
docker exec -it wims-minimal ./bin/apache-config
docker exec -it wims-minimal service apache2 restart
