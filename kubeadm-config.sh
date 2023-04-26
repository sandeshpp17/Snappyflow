kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address "0.0.0.0"

mkdir -p $HOME/.kube
yes | sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy weave for kubernetes network connections management

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

sleep 2

kubectl taint nodes --all node-role.kubernetes.io/master-


