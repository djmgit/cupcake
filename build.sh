#! /bin/bash

set -e

cd cupcake
echo "Building main.asm ..."
nasm -f elf main.asm
if [ `echo $?` != 0 ]; then
    echo "Compilation failed. Exiting runner ..."
    exit 1
fi
echo 'Compilation succeeded, proceeding with linking ...'
ld -m elf_i386 main.o -o cupcake
if [ `echo $?` != 0 ]; then
    echo "Linking failed. Exiting runner ..."
    exit 1
fi
echo 'Linking succeeded, proceeding with running'

cd ..
if [ ! -d "dist" ]
then
    mkdir dist
fi

echo "copying binary to dist"
cp src/cupcake dist/
