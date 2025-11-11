#!/bin/bash
# Tag all Docker images containing "speechmatics" for k3d local registry

REGISTRY="k3d-registry.localhost:5000"

# Get all images containing "speechmatics"
images=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep speechmatics)

if [ -z "$images" ]; then
  echo "No images found containing 'speechmatics'."
  exit 0
fi

for image in $images; do
  name=$(echo "$image" | cut -d':' -f1)
  tag=$(echo "$image" | cut -d':' -f2)
  
  new_image="$REGISTRY/$name:$tag"
  echo "Tagging $image → $new_image"
  docker tag "$image" "$new_image"
done

echo "✅ All matching images have been tagged for $REGISTRY"