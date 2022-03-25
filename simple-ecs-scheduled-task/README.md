# Simple ECS Scheduled Task
This repository sets up a simple ECS scheduled task for demo purposes.

## Getting started

### Prerequisites
Copy the set of files in this repository into a new project-specific folder. You will also need an AWS account with a set of API credentials that has sufficient permissions.

### Configuration
Create a new file named `.tfvars` in the project directory with the following contents:

```txt
aws_profile="<your-aws-profile-name>"
allowed_account_id="<your-aws-account-id>"
app_name="<your-app-name>"
stage="<stage>"
capacity_providers=<array of capacity providers>
```

Refer to the `variables.tf` file for more information. Note: this project assumes that you have installed the `aws-cli` and have set up local AWS profiles that you can reference.

### Instructions
To run Terraform to deploy our ECS, please follow the following steps.

#### Initialization
Before you can run any Terraform commands to set up infrastructure, you'll need to first initialize your Terraform working directory. This will install the necessary modules for your working directory. Run the following command:

```zsh
terraform init
```

You should see a stream of logs in your console. Once the initialization is successful, you should see the line `Terraform has been successfully initialized!`.

#### Terraform configuration validation
Once that is done, we want to validate that our Terraform configuration does not contain any erroneous syntax. Run the following command:

```zsh
terraform validate
```

On success, you should see the log `Success! The configuration is valid.`.

#### Dry run
Before we actually create any resources, we want to make sure that our Terraform configuration is doing what we want. Run the following command:

```zsh
terraform plan -var-file=<path to your .tfvars file>
```

This will print out Terraform's execution plan (the actions that Terraform will take on AWS) given the Terraform configuration file and the current state of your Terraform project. You can expect the logs printed by Terraform to end with a summary line which sums up the changes. An example summary line might be `Plan: 2 to add, 0 to change, 0 to destroy.`.

As a precaution, always remember to run `terraform plan` before you go ahead with your execution plan.

#### Execute
To go ahead and create the resources, run the following command:

```zsh
terraform apply -var-file=<path to your .tfvars file>
```

#### Teardown
Run the following command to remove all created infrastructure:

```zsh
terraform destroy -var-file=".tfvars"
```


