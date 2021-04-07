Project Name: aws-sample
=========

This is an exercise with AWS & Ansible:

  - [Goals](#goals)
  - [Setup Overview](#setup-overview)
  - [Example Playbook](#example-playbook)

Goals
------------

- Create a private subnet with an EC2 instance, and a public subnet with another EC2 instance also acting a NAT gateway for the first instance.
- Use Ansible to deploy Nginx & MySQL on the public instance and allow access from Internet to both services.

Setup Overview
--------------

**AWS VPC & Networking**

| Subnet  | CIDR        | Gateway              |
|---------|-------------|----------------------|
| public  | 10.0.0.0/24 | aws internet gateway |
| private | 10.0.1.0/24 | public/NAT instance  |

**EC2 Instances**

| Instance | Private IP | Security Group/Inbound Rules  | Elastic IP  | Public DNS Name                                      |
|----------|------------|-------------------------------|-------------|------------------------------------------------------|
| public   | 10.0.0.61  | HTTP, HTTPS, SSH, MySQL, ICMP | 3.0.122.232 | ec2-3-0-122-232.ap-southeast-1.compute.amazonaws.com |
| private  | 10.0.1.113 | SSH, ICMP                     | -           | -                                                    |

Terraform (1st task)
----------------

To accomplish the first goal, I use Terraform that carries out the following steps:

- Create the VPC
- Create the Internet gateway
- Create public subnet
- Add route table for public subnet with above Internet gateway as default route
- Create the security group for public instance that allows required inbound access from Internet as well as pass through the traffic from private subnet to Internet
- Create public instance, which can also act as NAT instance for private subnet
- Create private subnet
- Add route table for private subnet whose default route is public instance
- Create private instance

Ansible (2nd task)
----------------

Once the public instance is ready thanks to Terraform, Nginx and MySQL could simply be installed with the ansible playbook which calls two ansible roles named *mysql_install* and *nginx_install*
