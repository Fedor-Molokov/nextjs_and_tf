docker build -t devops-task .
docker create --name devops-task devops-task
docker cp devops-task:/app/.open-next/ ./out
docker rm devops-task
