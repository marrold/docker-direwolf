docker buildx build -t "marrold/vpe-direwolf:latest" --platform linux/amd64 --push .
docker buildx build -t "marrold/vpe-direwolf:latest" --platform linux/arm64 --push .
docker buildx build -t "marrold/vpe-direwolf:latest" --platform linux/arm/v6 --push .
docker buildx build -t "marrold/vpe-direwolf:latest" --platform linux/arm/v7 --push .
