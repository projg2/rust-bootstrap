#!/usr/bin/bash -e
: ${1:?missing target} ${3:?missing profile} ${RUST_VERSION:?missing RUST_VERSION}
# $1 - target, $2 - crossdev args, $3 - profile
if ! [[ -d /usr/${1} ]]; then
    MAKEOPTS="-j$(nproc)" crossdev ${2} --target ${1} --ov-output /var/db/repos/cross-${1}
    PORTAGE_CONFIGROOT=/usr/${1} eselect profile set ${3}
    if [[ ${2} == *--stable* ]]; then
        # force stable keywords
        sed -e '/ACCEPT_KEYWORDS/s/ ~${ARCH}//' -i /usr/${1}/etc/portage/make.conf
    fi
fi
LLVM_TARGETS="X86" USE="dist system-bootstrap" MAKEOPTS="-j$(nproc)" FEATURES="-parallel-fetch" ${1}-emerge --autounmask=y --autounmask-continue=y -v1 ~dev-lang/rust-${RUST_VERSION} --quiet-build y
printf '{"to": "ircs://irc.libera.chat:6697/%s", "privmsg":"%s"}' "#gentoo-tattoo" "arthurzam: [rust builder] ~dev-lang/rust-${RUST_VERSION} for $1 is done" > /dev/udp/127.0.0.1/6659