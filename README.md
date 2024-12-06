# Next.js in AWS

This archive contains brief instructions and sample project code intended for deployment.

The objectives of the task are as follows:
1. Develop a Terraform script that orchestrates the deployment of the application to a designated AWS account.
2. Demonstrate the basic functionality of the deployment through a working link.

Assume that the deployment process may be easily automated with GitHub Actions or any other CI/CD.
Avoid hardcoding specific identifiers, roles, regions, or other such details in the code.

## Build resources

First, run the build script

```bash
./build.sh
```

The `out` directory contains all code for AWS Lambda functions and other static resources.

## Deploy resources

From this point, you should proceed with the creation of an AWS infrastructure and the subsequent deployment of
AWS Lambda code and static assets.

Please adhere to the diagram and the recommendations provided in the documentation:

https://opennext.js.org/aws/inner_workings/architecture 

You must implement only the “**Core**” block from the diagram. The optional blocks
(“Warmer” and “ISR revalidation”) are not relevant to this task but can contribute to a higher score.

## Start web-server locally

In case of comparing the deployment with the ideal state, it’s possible to run the web-server locally
after the build step using the command:

```bash
docker run -it --rm --name devops-task -p 3000:3000 devops-task npm start
```
