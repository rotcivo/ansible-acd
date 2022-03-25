# ansible-acd
Deployment repo for configuring an ACD machine. 

Also contains some useful utilities for working with a private EC2 instance.

# Deployment
## Prerequisites
[AWS CLI v2+](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
[AWS Session Manager Plugin] (https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
[Ansible 2.9+](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
[Beezwax VPN](https://projects.beezwax.net/projects/beezteam/wiki/VPN)

## Base Deployment
The base deployment configures all the basic linux bits, including linux users. Nothing application specific here.
Make sure you're connected to the VPN in order to get the Zabbix host configuration done.
Dry-run (i.e. view the changes to be made)
```
./base-deployment.sh cww.beezwax.net --diff -vv --check
```
Apply the changes:
```
./base-deployment.sh cww.beezwax.net --diff -v
```

## Application Environment Deployment
The intent here is to get things installed that will be needed to deploy the application, but stop short of actully installing the application.
Dry-run (i.e. view the changes to be made)
```
./app-env-deployment.sh cww.beezwax.net --diff -vv --check
```
Apply the changes:
```
./app-env-deployment.sh --diff -vv
```

# Utilities
Utilities for connecting to a private EC2 instance.
## Prerequisites
* [AWS CLI v2+](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [AWS Session Manager Plugin] (https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
## SSM Shell
By default, a direct SSH connection to this EC2 instance is not possible. We get around this issue by using the AWS Systems Manager we've installed on the instance which allows us to get a shell without creating a direct SSH connection.

Before we begin, be sure you've got an AWS IAM user account set up. To request an account, send mail to it@beezwax.net and put a ticket in Redmine under 'User Support'.

The SSM Shell wrapper can connect either by supplying it the hostname (as provided in the EC2 instance 'Tag:hostname' or with the private IP address.

### Setup
Once all the prerequisites above are completed, please follow the steps below to get your local machine configured (assumes you're using a Linux or Mac machine). Note: you don't have to use the `--profile` option, and is only necessary when setting up multiple AWS CLI profiles for different roles, users or AWS accounts.

* Set up your AWS CLI profile and follow the prompts:
```
aws configure --profile [profile-name-of-your-choosing]
```
* Add some additional config items (optional)
```
aws configure set mfa_serial [mfa_serial_token] --profile [your-profile-name]
aws configure set role_arn [role_arn_token] --profile [your-profile-name]
aws configure set duration_seconds 43200 --profile [your-profile-name]
```

### Usage
Now that your profile is configured, you can log in to the EC2 instance with the following command:
```
./ssm-shell.sh [hostname] --profile [your-profile-name]
```
Example Output
```
> ./ssm-shell.sh cww.beezwax.net --profile beezwax-mfa
Enter MFA code for arn:aws:iam::333987864737:mfa/victor_o:

Starting session with SessionId: botocore-session-1647372421-0664f4c5af58023e9
$
```

## SSH Tunnel
This will start a Session Manager session to your target instance when the SSH client is used (i.e. scp, sftp, etc.) and main purpose is to be used in conjuction with an SSH client which supports ProxyCommand.

### Setup
* Copy wrapper command to ~/bin for the user on your local machine running the AWS CLI:
```
cp ssm-proxycommand-wrapper.sh ~/bin
```
* Add the following to your SSH config, ~/.ssh/config (e.g. cww)
```
Host cww.beezwax.net
  ProxyCommand ~/bin/ssh-aws.sh cww.beezwax.net us-west-1
```
* Test out the connection:
```
> ssh -i [ssh-key] deploy@cww.beezwax.net echo success
hello
A successful connection will output `success`. If you get an error, it may be a bad SSH key.
```
_Note:_ The ssh-key here will be once that you've supplied to the IT team. If this key needs to be updated, please let us know at it@beezwax.net and make a ticket in redmine in the `User Support` project.
