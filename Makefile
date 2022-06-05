dockerbuild:
	docker build -t cupcake .

dockerbuild_debug:
	docker build -t cupcake-debug -f DockerfileDev .

rundebug:
	docker run -it -p 9001:9001 -v /Users/dmondal/cupcake/cupcake:/src --name cupcake-debug cupcake-debug:latest
	docker rm cupcake-debug

clean-container:
	docker rm cupcake-debug

clean:
	rm cupcake/*.o cupcake/cupcake
