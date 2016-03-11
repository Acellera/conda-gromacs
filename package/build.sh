#!/bin/sh
printenv
pwd
export PATH="$PWD/cmake/bin:$PWD/bin:$PATH"

wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-5.1.2.tar.gz 
tar -zxf gromacs-5.1.2.tar.gz

mkdir build
cd build
mkdir -p "$SP_DIR"
cmake ../gromacs-5.1.2  -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=ON -DGMX_COOL_QUOTES=OFF -DBUILD_SHARED_LIBS=OFF -DGMX_SIMD=SSE4.1 -DCMAKE_INSTALL_PREFIX="$SP_DIR/../../.." -DGMX_PREFER_STATIC_LIBS=ON
make -j 2
make install
rm -rf "$SP_DIR/../../../include"
rm -rf "$SP_DIR/../../../lib64"
rm -rf "$SP_DIR/../../../share/man"

cd "$SP_DIR/../../../bin"
mv gmx gmx.bin
echo '#!/bin/sh

DIR=$(dirname "$0")
export GMXDATA="$DIR/share/gromacs"
export LD_LIBRARY_PATH="$DIR/lib:$LD_LIBRARY_PATH"
"$DIR/gmx.bin" "$@"
' >> gmx
chmod +x gmx

