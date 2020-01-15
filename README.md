# Terraform and Ansible LEMP Stack 
This is a little tutorial to use Terraform and Ansible to create a DigitalOcean Droplet with the LEMP Stack installed automatically.

## Infrastructure as Code

IaC is a method for writing and deploy configurations that can generate service components, can be applied to the entire IT world but is
specially used for Cloud-based Infrastucture as a Services and DevOps. 

DevOps requires automated workflows which can only be achieved through the assurance of high available and scalable IT Infraestructura.

### So, what is Terraform?

Terraform is an Open Source tool developed by Hashicorp that let us define our infrastructure as code. That means that it makes possible to convert a simple text definition to a real infrastructure using a simple programming language.

Terraform has support for serveral infrastructure providers local or cloud-based like:

- AWS
- DigitalOcean
- Azure
- etc

But you can always check the Official Documentation to see more: [Terraform ](https://www.terraform.io/docs/providers/index.html)

## Ansible

Ansible is an open-source IT automation engine that can automate cloud provisioning, configurations, applications deployments and some other IT needs.

It works connecting to our nodes and pushing small programs called "Ansible Modules" to them. 
Ansible can be executed over SSH (by default) and can remove them when is finished.

### Ansible Inventorys

Ansible can represent what machines it manages using a simple plain text file that can puts all our managed machines in groups of our choosing.

# Demo instructions:

## Prerequisites:
- Git installed.
- Terraform installed (v.0.12)
- Ansible-playbook installed.
- an SSH-KEY located on the default route ~/.ssh/id_rsa.pub


This demo will create the following resources on our DigitalOcean account: 

- 1 Load Balancer.
- 1 Small Droplet Instance.
- 1 Firewall Rule.


If you use Terraform you have to always make sure that you are creating all your soft infrastructure in it (as nodes, droplets, load-balancers).
Because if you "Destroy" your terraform always is going to destroy everything that you created and I promise, YOU WILL NOT WANT TO REMOVE DELICATE INFRASTRUCTURE, so please take care.

With that in Head we can start cloning this repository.

````
git clone git@github.com:ShankyJS/terraform-ansible.git && cd terraform-ansible
````

Now we have to copy our terraform variables that Terraform will use to manage our resources and to set our ssh key to our droplet.

````
cp terraform.tfvars.example terraform.tfvars
````

Open the file in your favorite code editor and you will se the following:

````
do_token = ""
ssh_fingerprint = ""
````

Fill each variable with:

- do_token: Personal Access Token for the DigitalOcean API.
- ssh_fingerprint: DigitalOcean API refers to SSH keys using their fingerprint, you can get it with this:

````
ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | awk '{print $2}'
````

Please copy the result of that command without the md5 and paste it into the variable.

## Running Terraform and Ansible.

With all set it up we can start our terraform with:

````
terraform init
````

This will download the providers config and other stuff that Terraform need to handle our requests.

Is a good practice to know what Terraform is going to do so please do: 

````
terraform plan
````

This is going to output all the resources that are going to be created.

Now we can confirm Terraform with:

````
terraform apply --auto-approve
````

### WAITING TIME

````
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

ip = 159.89.220.42

````
When the apply is finished we can see an output IP, that's the IP of our loadbalancer but in this moment if we try to navigate in our browser
the droplet is not serving anything.

So here is when we can deploy our Ansible playbooks so please.

````
cd Ansible && ansible-playbook -i inventory ansible.yml
````

Now if we browse again to the IP we are going to see the Apache Default page (because PHP installed it on the default route /var/www/html).


### Destroy everything.

Please remember to destroy your demo infra using Terraform:

````
terraform destroy
````

(Do this command where the terraform.tf is located).

# Conclusion

Today we see a little demo of Terraform and Ansible, I can say that run Ansible is not always the best option, you can set it up to run the Ansible playbooks on the server-side and that is good cause you don't have to install ansible.

I highly recommend to check the Terraform.tf and Providers.tf file to see how Terraform is working. And ansible.yml to see the tasks that Ansible performed.
