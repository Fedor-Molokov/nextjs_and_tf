docker build -t devops-task .
docker create --name devops-task devops-task
docker cp devops-task:/app/.open-next/ ./out
docker rm devops-task
zip -r ./out/image-optimization-function.zip ./out/image-optimization-function
zip -r ./out/revalidation-function.zip ./out/revalidation-function
zip -r ./out/server-functions.zip ./out/server-functions
zip -r ./out/warmer-function.zip ./out/warmer-function