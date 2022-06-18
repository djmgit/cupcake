# this is dockerfile should be used for creating the development
# image, mostly for development on non linux machines.

FROM ubuntu:18.04

WORKDIR /cupcake
ADD cupcake /cupcake/cupcake
ADD build.sh /cupcake

# install dependencies
RUN apt update && \
    apt install -y binutils && \
    # for debugging
    apt install -y vim && \
    # a simple pid 1 process for handling of singnals
    apt install -y dumb-init && \
    #make script executable
    chmod +x build.sh && \
    # finally install nasm
    apt install -y nasm && \
    ./build.sh

ENTRYPOINT [ "dumb-init", "dist/cupcake", "/docroot" ]
