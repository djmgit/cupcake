#! /bin/bash

set -e

cd /src

echo "Building main.asm ..."
nasm -f elf main.asm
if [ `echo $?` != 0 ]; then
    echo "Compilation failed. Exiting runner ..."
    exit 1
fi
echo 'Compilation succeeded, proceeding with linking ...'
ld -m elf_i386 main.o -o out
if [ `echo $?` != 0 ]; then
    echo "Linking failed. Exiting runner ..."
    exit 1
fi
echo 'Linking succeeded, proceeding with running'
