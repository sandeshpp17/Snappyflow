#!/bin/bash
echo "update VM"
yum update -y
yum upgrade -y

echo "firewall disabled and swap off"
if [[ `firewall-cmd --state` = running ]]
then

systemctl disable firewalld
systemctl stop firewalld
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
    echo "firewall is inactive and swap is also off"
else
    echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
    swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab
    firewall_status=inactive
    echo "firewall is already inactive and swap is also off"
fi

echo "cehck docker install or not"
if [[ $(docker -v | grep '19.03') ]]; then
    echo 'Docker version 19.03.!  already installaed '
else
    echo 'Docker version not 19.03.! or may be not installed Now we can installed '
        #yum versionlock clear
yum install -y yum-utils device-mapper-persistent-data lvm2 curl wget yum-plugin-versionlock
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

mkdir /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF



mkdir -p /etc/systemd/system/docker.service.d
        yum install -y docker-ce
        echo "Docker installed completed"
        echo "restart docker service"
        systemctl daemon-reload
        systemctl restart docker
        systemctl enable docker.service
        systemctl start docker
fi

echo " Now we can strat installation for kubernetes v1.19.3 "


if [[ $(kubeadm version  | grep 'v1.19.3') ]]; then
    echo 'kubeadm version v1.19.3 is already installed'
else
   echo 'kubeadm version may be old or not installed so we can installed it'
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
        # yum versionlock clear
        yum install -y  kubectl-1.19.3 kubeadm-1.19.3 kubelet-1.19.3
        yum versionlock kubectl-1.19.3 kubeadm-1.19.3 kubelet-1.19.3
        echo "kubernetes version 1.19.3 is installed"

        echo "restart docker service"
systemctl enable kubelet
systemctl start kubelet
fi

echo "pull kubeadm config images"
kubeadm config images pull
echo "k8s and docker installed properly "
