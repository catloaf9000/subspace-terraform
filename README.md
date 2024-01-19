# Subspace VPN with AWS terraform

## Create infrastructure with

```bash
terraform apply
```

## Configure server

Connect to server via ssh. Terraform uses default ~/.ssh/id_rsa.pub key, override if necessary

### Install WireGuard on host

```bash
sudo su

apt-get update
apt-get install -y wireguard

# Remove dnsmasq because it will run inside the container.
apt-get remove -y dnsmasq

# Disable systemd-resolved listener if it blocks port 53.
echo "DNSStubListener=no" >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved

# Set Cloudfare DNS server.
cp /etc/resolv.conf /etc/resolv.conf.copy
# Remove symlink /etc/resolv.conf so it will not be overwritten by Ubuntu
rm /etc/resolv.conf
echo nameserver 1.1.1.1 > /etc/resolv.conf
echo nameserver 1.0.0.1 >> /etc/resolv.conf

# Load modules.
modprobe wireguard
modprobe iptable_nat
modprobe ip6table_nat

# Enable modules when rebooting.
echo "wireguard" > /etc/modules-load.d/wireguard.conf
echo "iptable_nat" > /etc/modules-load.d/iptable_nat.conf
echo "ip6table_nat" > /etc/modules-load.d/ip6table_nat.conf
  
# Check if systemd-modules-load service is active.
systemctl status systemd-modules-load.service

# Enable IP forwarding.
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
```

### Install docker

```bash
cd /tmp
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/containerd.io_1.6.9-1_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce_24.0.7-1~ubuntu.20.04~focal_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-cli_24.0.7-1~ubuntu.20.04~focal_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-buildx-plugin_0.11.2-1~ubuntu.20.04~focal_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-compose-plugin_2.6.0~ubuntu-focal_amd64.deb

dpkg -i ./containerd.io_1.6.9-1_amd64.deb \
./docker-buildx-plugin_0.11.2-1~ubuntu.20.04~focal_amd64.deb \
./docker-ce-cli_24.0.7-1~ubuntu.20.04~focal_amd64.deb \
./docker-ce_24.0.7-1~ubuntu.20.04~focal_amd64.deb \
./docker-compose-plugin_2.6.0~ubuntu-focal_amd64.deb

service docker start
docker run hello-world
```

### Start docker

```bash
mkdir /data
docker create \
    --name subspace \
    --restart always \
    --network host \
    --cap-add NET_ADMIN \
    --volume /data:/data \
    --env SUBSPACE_NAMESERVERS="1.1.1.1,8.8.8.8" \
    --env SUBSPACE_LISTENPORT="51820" \
    --env SUBSPACE_HTTP_HOST="subspace.mahurin.xyz" \
    --env SUBSPACE_IPV4_POOL="10.99.0.0/16" \
    --env SUBSPACE_IPV4_GW="10.99.0.1" \
    --env SUBSPACE_THEME=blue \
    subspacecommunity/subspace:amd64-v1.5.0

docker start subspace

docker logs -f subspace
```