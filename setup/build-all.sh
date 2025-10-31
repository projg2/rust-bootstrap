#!/bin/bash -e

# mips / abi_mips_o32 / big-endian / glibc
rust_bootstrap.sh "mips-linux-gnu" "--abis o32" "default/linux/mips/23.0/split-usr/o32"

# mips / abi_mips_o32 / !big-endian / glibc
rust_bootstrap.sh "mipsel-linux-gnu" "--abis o32" "default/linux/mips/23.0/split-usr/mipsel/o32"

# mips / abi_mips_n64 / big-endian / glibc
rust_bootstrap.sh "mips64-linux-gnuabi64" "--abis n64" "default/linux/mips/23.0/split-usr/n64"

# mips / abi_mips_n64 / !big-endian / glibc
rust_bootstrap.sh "mips64el-linux-gnuabi64" "--abis n64" "default/linux/mips/23.0/split-usr/mipsel/n64"

# riscv / 64 bit / lp64d / musl
rust_bootstrap.sh "riscv64-linux-musl" "" "default/linux/riscv/23.0/rv64/split-usr/lp64d/musl"

# ppc / 64 bit / little-endian / musl
# officially supported by Rust
#rust_bootstrap.sh "powerpc64le-linux-musl" "--stable" "default/linux/ppc64le/23.0/split-usr/musl"

# ppc / 64 bit / big-endian / musl
rust_bootstrap.sh "powerpc64-linux-musl" "--stable" "default/linux/ppc64/23.0/split-usr/musl"

# sparc / 64 bit / big-endian / glibc
rust_bootstrap.sh "sparc64-linux-gnu" "--stable" "default/linux/sparc/23.0/split-usr/64ul"
