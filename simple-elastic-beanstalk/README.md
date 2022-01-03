# Simple Elastic Beanstalk

This repository sets up a simple Elastic Beanstalk environment with an RDS Postgres instance for demo purposes.

## Getting started

### Prerequisites

Copy the set of files in this repository into a new project-specific folder. You will also need an AWS account with a set of API credentials that has sufficient permissions.

### Installation

Install `terraform` via `homebrew`

```zsh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Install the `aws-cli` by following the official instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

### Configure credentials

Configure the `aws-cli` from your terminal by following the prompts to input your AWS Access Key ID and Secret Access Key.

```zsh
aws configure
```

Alternatively, supply your credentials by modifying the `~/.aws/credentials` file directly:

```txt
[your-aws-profile-name]
aws_access_key_id=<your-aws-access-key-id>
aws_secret_access_key=<your-secret-access-key>
```

### Initialise your project directory

```zsh
terraform init
```

Terraform downloads the aws provider and installs it in a hidden subdirectory of your current working directory, named `.terraform`. The terraform init command prints out which version of the provider was installed. Terraform also considers the existing lock file named `.terraform.lock.hcl` which specifies the exact provider versions used, so that you can control when you want to update the providers used for your project.

### Configure secrets

Create a file named `.tfvars` with the following contents:

```.tfvars
aws_profile="<your-aws-profile-name>"
allowed_account_id="<your-aws-account-id>"
app_name="<your-app-name>
db_root_user="postgres"
db_root_password="<your-database-password>"
```

### (optional) disallow publicly accessible database

In `main.tf`:

1. Delete the code section indicated by `BEGIN: for publicly accessible database` and `END: for publicly accessible database`.
2. Delete the line `publicly_accessible = true` in the `"db"` module.

### Initialise Terraform

Initialise the new Terraform working directory with the following command:

```zsh
terraform init
```

This will install the necessary modules for your working directory. You should see output similar to the following:

```zsh
Initializing modules...
(truncated)

Initializing the backend...

Initializing provider plugins...

(truncated)

Terraform has been successfully initialized!
```

### Create infrastructure

First, create a new Terraform *workspace* called "staging":

```zsh
terraform workspace new staging
```

This will help to identify and isolate staging resources from any production resources you may create in future, should you choose to do so.

Next, execute the following command to create your cloud infrastructure

```zsh
terraform apply -var-file=".tfvars"
```

You should see output similar to the following:

```zsh
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

(...)

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Take your time to examine the planned changes, and type `yes` to proceed.
