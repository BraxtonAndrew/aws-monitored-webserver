# aws-monitored-webserver
Terraform + CI/CD + monitoring project

## Things I learned
- I assumed Amazon Linux 2 used 'dnf' as the package manager. I learned through the EC2 logs that 'dnf' was not recognized and I changed it to 'yum' instead.
- I tried to use 'yum install nginx'. I learned through the EC2 logs that I should be using 'amazon-linux-extras install nginx1' instead.