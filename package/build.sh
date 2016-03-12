#!/bin/sh
printenv
pwd
export PATH="$HOME/cmake/bin:$HOME/bin:$PATH"

wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-5.1.2.tar.gz 
tar -zxf gromacs-5.1.2.tar.gz

mkdir build
cd build
mkdir -p "$SP_DIR"
CC=gcc-4.4 CXX=g++-4.4 FC=gfortran-4.4 cmake ../gromacs-5.1.2  -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=ON -DGMX_COOL_QUOTES=OFF -DBUILD_SHARED_LIBS=OFF -DGMX_SIMD=SSE4.1 -DCMAKE_INSTALL_PREFIX="$SP_DIR/../../.." -DGMX_PREFER_STATIC_LIBS=ON -DGMX_EXTERNAL_BLAS=OFF LAPACK_lapack_LIBRARY=/usr/lib/liblapack.a HAVE_LIBM=/usr/lib/x86_64-linux-gnu/libm.a BLAS_atlas_LIBRARY=/usr/lib/libatlas.a BLAS_f77blas_LIBRARY=/usr/lib/libf77blas.a
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

