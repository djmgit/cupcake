# Cupcake

Cupcake is a tiny, simple webserver with very limited features written completely in x86 (32 bit) assembly from scratch and uses the Netwide Assembler
also known as NASM for assembling. As of the time of writing this doc, Cupcake only supports serving static files from a given docroot and is 
capable of showing a 404 response page if asked for an unknown resource. Cupcake requires linux based operating system to run since it uses the standard 
linux system calls for interacting with the kernel.
Cupcake is created with the pure intention of having fun with x86 assembly language and learning and exploring the same with NASM.
The other intension was to practically learn more about how system calls in linux kernel gets invoked at the low level and get more
familiarity with the linux syscall ABI.

## Building and running Cupcake

### Linux based OS

Cupcake can be built and run in a pretty straight forward way on machines running a linux based OS. As a prerequisite make sure you have NASM and
GNU binutils package installed. We require binutils as it provides the linker ld which we will use to link the outout of our assembler in order
to generate an elf file.
Note: Cupcake has been developed using NASM version : 2.13.02 and GNU binutils version : 2.30

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

Now lets fire up Cupcake using the following command:

```
./dist/cupcake <path_to_the_created_docroot>
```
I usually prefer providing absolute path when working with paths.

Cupcake should greet you with the following series of messages in your terminal:
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

The content of the index.html you just created should get printed as output on your terminal. You can also send the request using a web browser like
firefox or chrome.

**What does the make command do?***

If you check the Makefile, then what you will see is that make simply runs the first recipe which is ```build```, which runs the build script.
The build script essentially first assembles our code using nasm assembler with elf32 as the target format.

```
nasm -felf main.asm
```

Providing only main.asm is enough since that is entry point of our code and other files are included as required using ```#include``` calls.
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
Once again we forward port 9001. Next we mount the source code directory which is ```cupcake``` under the project root
to ```/src``` on docker as mountpoint.
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

## How does Cupcake work

I will try to not go too much into this since I have tried to provide as much inline documention as possible. Most of the interesting areas of
the code have enough comments (hopefully). Still, lets try to understand what Cupcake does and how does it do what it does.

Just like any other webserver, Cupcake makes using of network sockets at its heart. In short, it sets up a listenning socket, listens for incoming
connections, accepts connections, reads data, generates response and writes back the response into the accepted client socket. It follows the
traditional fork model of web servers where every new connecting is handled in a separate process so that other connections are not waiting.

The entry point to the server is ```main.asm```. When it boots up the following things happen:

- The cmdline arguments are parsed so that cupcake knows the docroot location.
- A new linux network socket is created.
- The created socket is ```bind```ed to an IP and PORT. Port is hardcoded to be 9001
- The socket is then put to listenning mode.
- The socket then starts to listen for new connections. This is the blocking step where our server loop is blocked and waiting for a new connection.
- Whenever the accept call gets a new connection, we get a new client socket fd. When that happens we ```fork``` a new process.
- This new process reads data from the client socket fd. Unlike a real world production grade webserver, we are not interested in the entire request data   since we only allow ```GET``` requests that too for static files from a given location. So we read a chunk of byte (hardcoded size).
- From the chuck of data we read we try to extract required information which is the HTTP path requested. Next we prepend the docroot path infront of       this HTTP path read. For example if the path was ```index.html``` and the docroot is ```/var/docroot```, the final resurce path to read from becomes  ```/var/docroot/index.html```.
- Next we try to read the resource (basically file) pointed to by the resource path. If we are not able to read that, may be because file does not         exists (or any other issue), we simple send back the 404 resource not found page.
- If the file exists then we open it and read it byte by byte. Cupcake expects a file with a fixed given limit (hardcoded once agan).
- Once the file is read, we generate the http response with the desired ```Content-Length``` header which is basically the size of the file read in         bytes.
  The usual format of an HTTP response is as follows (example):
  
  ```
  HTTP/1.1 200 OK
  Content-Type: text/html
  Content-Length: <the_length_of_content_in_bytes>
  <other_such_headers_if_any>
  <exactly_one_blank_line>
  the resource content returned by the server like
  Hellow world from Cupcake, etc ...
  ```
  
  The file content we read goes right after the blank line. Also you would not want to miss that blank line after the headers.
  Without that innocent looking blank line the entire response becomes invalid and no http client will be able to render/show the response.
- Finally we write the generated HTTP response back to the client socket fd and then close the socket.

## Things I would like to add/improve

Right now the project is pretty crude. As I mentioned already, ths is not for real world use, its not even close to the full feature suite provided
by a real world webserver but that was never the intention anyways. Having said that, there is still quite a few ineteresting things that I would like
to add/fix. Hope I will do that if I dont become distracted with something else...

- Several things are hardcoded right now, for example how long a HTTP path can be or how long the content read should be and lots more. Those things       should be dynamic.
- Several parts of the code are rigid and too specific, those should be made more generic and moved to its own file or a macro.
- Implement a redirect (302) with a default page at ```/```. I should have done this, but I guess I am just being lazy.
- Error messages.
- The most interesting one I guess, reap the child processes created. Currently Cupcake will create several defunct process when running natively on the   host. This is because the forked processes are not being reaped by the parent.

Also I would like to mention ```gcc -S``` was not used while developing this, that would have killed the fun.

