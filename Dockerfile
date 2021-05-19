# Container image that runs your code
FROM swift:5.3
LABEL Description="Docker Container for GitHub action swift-package-dependencies-check"
LABEL repository="http://github.com/MarcoEidinger/swift-package-dependencies-check/edit/main/Dockerfile"
LABEL maintainer="Marco Eidinger <eidingermarco@gmail.com>"

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
