# Kubernetes install scripts on centos 7.x


In this file we have the centos-prerequisites and kubeadm-config scripts that are useful for installing and deploying kubernetes in centos 7.x OS.

you can use the centos-prerequisites for installing docker and kubernetes.

# sh centos-prerequisites.sh

And, kubeadm-config is a script which is used to configure stand-alone kubernetes cluster.

# sh kubeadm-config.sh

we can configure the weave network using below command and file.

# kubectl apply -f weave-net.yaml
