#!/bin/bash

# - wget https://www.libsdl.org/release/SDL2-devel-2.0.5-VC.zip && unzip SDL2-devel-2.0.5-VC.zip
# - wget http://openal-soft.org/openal-binaries/openal-soft-1.17.2-bin.zip && unzip openal-soft-1.17.2-bin.zip
# - (git clone https://github.com/HaxeFoundation/hashlink && cd hashlink && git checkout f9ac7acdb2d82661d9d77c1a44972e90cc331b98 && mv ../SDL2-2.0.5 include/sdl && mv ../openal-soft-1.17.2-bin include/openal && sed -i 's/^LIBFLAGS =/LIBFLAGS = -L./' Makefile && sed -i 's/libhl hl libs/libhl hl/' Makefile && make all && cp hl /usr/local/bin/ && sudo ldconfig && hl --version)
git clone https://github.com/HaxeFoundation/hashlink

cd hashlink
git checkout f9ac7acdb2d82661d9d77c1a44972e90cc331b98 

sed -i 's/^LIBFLAGS =/LIBFLAGS = -L./' Makefile
sed -i 's/libhl hl libs/libhl hl/' Makefile
sed -i 's/varray \*narr = hl_alloc_array(&hlt_bytes,count)/varray \*narr = hl_alloc_array(&hlt_bytes,ncount)/' src/std/sys.c 

ARCH=32 make all 

sudo cp hl /usr/local/bin/ 
sudo cp libhl.so /usr/local/lib 
sudo ldconfig 

hl || true
