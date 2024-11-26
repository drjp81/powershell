docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name cibuilder --driver docker-container --use
docker buildx ls
docker buildx inspect --bootstrap
docker buildx build --platform=linux/amd64,linux/arm64,linux/arm/v7 -f dockerfile -t drjp81/powershell:latest --push . --progress=plain