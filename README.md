# Cupcake

Cupcake is a tiny, simple webserver with very limited features written completely in x86 (32 bit) assembly from scratch and uses the Netwide Assembler
also known as NASM. As of the time of writing this doc, Cupcake only supports serving static files from a given docroot and is capable of showing
a 404 response page if asked for an unknown resource. Cupcake requires linux based operating system to run since it uses the standard linux system calls 
for interacting with the kernel.
Cupcake is created with the pure intention of having fun with x86 assembly language and learning and exploring the same with NASM.
The other intension wasto practically learn more about how system calls in linux kernel gets invoked at the low level and get more
familiarity with the linux syscall ABI.

## Building and running Cupcake

### Linux based OS

Cupcake can be built and run in a pretty straight forward way on machines running a linux based OS. As a prerequisite make sure you have NASM and
GNU binutils package installed. We require binutils as it provides the linker ld which we will use to link the outout of our assembler in order
to generate an elf file.
Note: Cupcake has been developed using NASM version :  2.13.02 and GNU binutils version : 2.30

- First clone this repository to your local.
- Open up the repository in your terminal.
- Build Cupcake using : ```make```
- This will produce the built and linked elf under the dist directory.

Cupcake requires you to provide a directory to serve as a command line arg, the only arg it takes mandatorily. So basically this directory becomes your
docroot.
So make a new directoy called docroot : ```mkdir docroot```
Save the following HTML file as ```index.html``` under docroot or create any HTML content of your choice.

```
<html>
  <head>
    <h1>Hello from Cupcake</h1>
  </head>
</html>
```

Now lets fire up Cupcake using the following

```
./dist/cupcake <path_to_the_create_docroot>
```
I usually prefer providing absolute path when working with paths.

Cupcake should greet you with the following sereies of messages in your terminal:
```
Starting cupcake on port 9001 ...
Creating socket ...
Binding socket to 0.0.0.0:9001 ...
Attempting to listen ...
Cupcake is listenning for new connections ...
```

This means Cupcake has successfully started and is now waiting for new client connections on port 9001 (yeah the port is hardcoded).

Now you can send a request to cupcake. I will use curl to send an HTTP request:

```
curl -v http://127.0.0.1:9001/index.html
```

The content of the index.html you just created should get printed as output on your terminal.

**What does the make command do?***

if you check the Makefile, then what you will see is that make simply runs the first recipe which is ```build```, which runs the build script.
The build script essentially first assembles our code using nasm assembler with elf32 as the target format.

```
nasm -felf main.asm
```

Providing only main.asm is enough since that is entry point of our code and other files are include as required using ```#include``` calls.
This provides a ```main.o``` assembled object file which is not executable.
Next we invoke the linker to link this file and procvide us with a executable file.

``` ld -m elf_i386 main.o -o cupcake ```

This provides a executable named ```cupcake``` targetted for the x86 (32 bit) arch processor.

### Running via Docker

There is also a Dockerfile provided to build and run Cupcake in Docker.
To build the image, simply run:

```
make dockerbuild
```

which simply runs:

``` 
docker build -t cupcake .
```

So the image created has the name/tag cupcake. No versioning, however you can always fire this command directly to add versioning to your local images.

To run, you can use the following docker run command:

```
docker run -p 9001:9001 --rm -v <absolute_path_to_docroot_on_your_host>/:/docroot --name cupcake cupcake
```

In this command, we forward 9001 port on the host machine to 9001 port of docker since thats where cupcake will be listenning. Also we mount the folder
that we want to serve on docker at ```/docroot``` mount point. If you see the Dockerfile we start the server with

```
CMD ["dumb-init", "/dist/cupcake", "/docroot"]
```
hence the mount point is ```/docroot```

### Running via docker in debug mode (Usefull if developing on non-linux machine like MacOS)

If you dont have a linux machine but still want to play around may be on MacOS, then you can do so in debug mode which is nothing but
a ubuntu docker container running in interactive mode with the entire source code mounted to it. The container already has got the essential
tools like NASM, ld etc. Yeah that simple and crude.

Start the debug container:

```
make rundebug
```

this basically runs the following under the hood
```
docker run -it -p 9001:9001 -v `pwd`/cupcake:/src -v `pwd`/build.sh:/src/build.sh -e mode=debug --rm --name cupcake-debug cupcake-debug:latest
```
Once we forward port 9001. Next we mount the source code directory which is ```cupcake``` under the project root to ```/src``` on docker as mountpoint.
Also we mount the build script ```build.sh``` at ```/src/build.sh``` the practical implication of which is we get the build script available in the
source code directory itself. The debug image has got ```/src``` set as the ```WORKDIR``` so as soon as we run the above command we find ourselves
in the source code directory. 
Now all you have to do is make changes to the code files, then assemble and link using:

```
./build.sh
```

and then run using:

```
./cupcake <path_to_docroot>
```
