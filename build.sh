#!/bin/bash

rdmd --build-only --force -unittest -g -debug -of"bin/engine" -I"src" -I"../" -I"/usr/include/d" src/app.d

if [ $? -eq 0 ]
then
	cd bin
	./engine
fi


