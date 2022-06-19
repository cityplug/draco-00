docker network create -d macvlan \
    --subnet=192.168.50.0/24 \
    --gateway=192.168.50.1 \
    -o parent=eth0 draco_net

echo
sudo docker-compose up -d

# ----> Next Script
./finish.sh