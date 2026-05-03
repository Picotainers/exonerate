# exonerate
Source-built container image for `exonerate`.

## Quick Usage

```bash
# Pull the image
docker pull docker.io/picotainers/exonerate:latest

# Run the tool
docker run --rm -v "$(pwd):/data" docker.io/picotainers/exonerate:latest exonerate --help
```
