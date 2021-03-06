#!/bin/sh

printenv
pwd
export PATH="$HOME/cmake/bin:$HOME/bin:$PATH"
VER=5.1.2

if [ ! -e "gromacs-${VER}.tar.gz" ]; then
	wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-${VER}.tar.gz 
	tar -zxf gromacs-${VER}.tar.gz
fi

mkdir build
cd build

export CC=gcc-4.4
export CXX=g++-4.4
export FC=gfortran-4.4

if [ "$SP_DIR" == "" ]; then
	export PREFIX=/tmp/
else
	export PREFIX="$SP_DIR/../../../"
fi
mkdir -p "$PREFIX"

export CUDA_HOME="$(dirname $(which nvcc))/../"

ln -s $(which gcc44) "$HOME/bin/gcc"
cmake ../gromacs-5.1.2  -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=ON -DGMX_COOL_QUOTES=OFF -DBUILD_SHARED_LIBS=OFF -DGMX_SIMD=AVX_256 -DCMAKE_INSTALL_PREFIX="$PREFIX" -DGMX_PREFER_STATIC_LIBS=ON -DGMX_EXTERNAL_BLAS=OFF  -DGMX_EXTERNAL_LAPACK=OFF  -DGMX_BUILD_SHARED_EXE=ON -DCUDA_CUDART_LIBRARY="${CUDA_HOME}/lib64/libcudart_static.a"  -DCMAKE_C_FLAGS="-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0"

# Fix CMAKE brain-damage
#echo "Fix CMAKE"
#find /usr -name "librt.a"
#find . -name link.txt -exec  sed -i 's/-lpthread/& -ldl/g' {} \; -print
#find . -name link.txt -exec sed -i 's/-lrt/\/usr\/lib\/x86_64-linux-gnu\/librt.a /g' {} \; -print 
#find . -name link.txt -exec sed -i 's/\/usr\/lib\/x86_64-linux-gnu\/librt.so/ /g' {} \; -print 
#find . -name link.txt -exec  sed -i 's/$/& \/usr\/lib\/x86_64-linux-gnu\/libc.a/g' {} \; -print
#
cat ./src/programs/CMakeFiles/gmx.dir/link.txt
cat ./share/template/CMakeFiles/template.dir/link.txt

make  install
#find . -name link.txt -exec sed -i 's/-lpthread/& -ldl/g' {} \; -print
#find . -name link.txt -exec sed -i 's/-lrt/\/usr\/lib\/x86_64-linux-gnu\/librt.a /g' {} \; -print 
#make install

rm -rf "$PREFIX/include"
rm -rf "$PREFIX/lib64"
rm -rf "$PREFIX/share/man"

cd "$PREFIX/bin"
mv gmx gmx.bin
echo '#!/bin/sh

DIR=$(dirname "$0")
export GMXDATA="$DIR/share/gromacs"
export LD_LIBRARY_PATH="$DIR/../lib/compat-libc:$LD_LIBRARY_PATH"
"$DIR/gmx.bin" "$@"
' >> gmx
chmod +x gmx

