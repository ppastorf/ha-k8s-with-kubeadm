## AWS instances and VCP for the HA Kubernetes with Kubeadm lab

Per default configs, it should deploy 2 control plane nodes, 1 worker plane node and one host for Nginx, which is the minimal setup for the HA cluster.

## Price estimation
For the four machines deployed, [Infracost](https://github.com/infracost/infracost) says that it should cost $113 monthly, which is around $0.15 per hour. The lab should take no more than one or two hours.

## Instructions
1. [Install terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. Authenticate:
- Generate access key in AWS UI
- Export as env variable:
```
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

3. Configs
- Review `locals` on aws/main.tf

4. Deploy
```
cd aws/
terraform init
terraform plan
terraform apply
```

Get the IPs from the output, SSH, become root and start the lab.
```
terraform output
ssh -i ~/.ssh/id_rsa ubuntu@$PUBLIC_IP
sudo -i
```

You can put the scripts to the remote hosts with SCP
```
scp -i ~/.ssh/id_rsa ./scripts/* ubuntu@$PUBLIC_IP:/home/ubuntu/
```

And config files with SSH because of directory permissions
```
cat ./config/kubeadm-init.conf | ssh ubuntu@$PUBLIC_IP "sudo mkdir -p /etc/kubernetes; sudo tee -a /etc/kubernetes/kubeadm.conf" > /dev/null
```

5. After done, you can cleanup with TF
```
cd aws/
terraform destroy
```
