#!/bin/bash

ret=0
for target in mips-linux-gnu mipsel-linux-gnu mips64-linux-gnuabi64 mips64el-linux-gnuabi64 \
		riscv64-linux-musl powerpc64-linux-musl sparc64-linux-gnu ; do
	# This can be needed because of cross quirks with cross-* vs the things inside the root
	${target}-emerge --keep-going=y -u @system
	: $(( ret |= $? ))

	# Actually update misc libs like zlib, openssl, whatever else Rust might need
	${target}-emerge --keep-going=y -uvDN @world
	: $(( ret |= $? ))
done

exit ${ret}
