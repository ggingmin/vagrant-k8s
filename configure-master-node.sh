#!/bin/bash -e

MASTER_NODE=172.16.8.10
POD_NETWORK_CIDR=192.168.0.0/16

initialize_master_node ()
{
sudo systemctl enable kubelet
sudo kubeadm config images pull
sudo kubeadm init --apiserver-advertise-address=$MASTER_NODE --pod-network-cidr=$POD_NETWORK_CIDR --ignore-preflight-errors=NumCPU
}

create_join_command ()
{
kubeadm token create --print-join-command | tee /vagrant/join_command.sh
chmod +x /vagrant/join_command.sh
}

configure_kubectl () 
{
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

install_network_cni ()
{
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

# install_metrics_server ()
# {
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# }

install_kubernetes_dashboard ()
{
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
}

# create_dashboard_user ()
# {
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: admin-user
#   namespace: kubernetes-dashboard
# EOF

# cat <<EOF | kubectl apply -f -
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRoleBinding
# metadata:
#   name: admin-user
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: cluster-admin
# subjects:
# - kind: ServiceAccount
#   name: admin-user
#   namespace: kubernetes-dashboard
# EOF

# sudo -i -u vagrant bash << EOF
# mkdir -p /home/vagrant/.kube
# sudo cp -i /vagrant/configs/config /home/vagrant/.kube/
# sudo chown 1000:1000 /home/vagrant/.kube/config
# EOF
# }



initialize_master_node
configure_kubectl
install_network_cni
# install_metrics_server
install_kubernetes_dashboard
create_join_command
# create_dashboard_user