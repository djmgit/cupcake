build:
	cp build.sh cupcake && \
	cd cupcake && \
	./build.sh
	rm cupcake/main.o cupcake/build.sh

dockerbuild:
	docker build -t cupcake .

dockerbuild_debug:
	docker build -t cupcake-debug -f DockerfileDev .

rundebug:
	docker run -it -p 9001:9001 -v `pwd`/cupcake:/src -v `pwd`/build.sh:/src/build.sh -e mode=debug --rm --name cupcake-debug cupcake-debug:latest

clean-container:
	docker rm cupcake-debug

clean:
	rm cupcake/*.o cupcake/cupcake
