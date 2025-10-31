#!/usr/bin/env bash

INPUT_DIR=${1?:"
Usage : ${0} <input_dir> <output_dir>"}
OUTPUT_DIR=${2?:"
Usage : ${0} <input_dir> <output_dir>"}

set -e
source /lib/gentoo/functions.sh || :

tarext=".tar.xz"

find_txz() {
	local -n arr="${1}"
	IFS= mapfile -d '' arr < <(find "${INPUT_DIR}" -maxdepth 1 -xtype f \
		-iname "*${tarext}" -print0  2>/dev/null | sort -Vurz - -- )
}

main() {
	ebegin "Creating temporary directory"
	local tmpdir="$(mktemp -t -d rust-repack.XXXXXXXXXX)"
	trap '{ rm -rf -- "${tmpdir}"; }' EXIT
	cd "${tmpdir}"
	echo "${tmpdir}"
	eend ${?}

	# standard mandatory components
	local components=(
		rustc
		cargo
		rust-std-TARGET
	)

	einfo "Searching for *${tarext} files with rust components"
	local txz txzs
	find_txz txzs
	for txz in "${txzs[@]}"; do
		ewarn "${txz}"
	done

	if [[ ${#txzs[@]} -lt 3 ]]; then
		eerror "number of tarballs found less than 3"
	fi

	local stdfile target version
	stdfile="$(basename "${txzs[0]}")"
	target="${stdfile%${tarext}}"
	target="${target#rust-std-}"
	target="${target#*-}"
	einfo "Detected ${target} target"
	components=( ${components[@]/rust-std-TARGET/rust-std-${target}} )

	version="${stdfile#rust-std-}"
	version="${version%%-*}"
	einfo "Detected ${version} version"

	einfo "Unpacking component tarballs"
	eindent
	for txz in "${txzs[@]}"; do
		ebegin "Unpacking to ${tmpdir}/${txz%${tarext}}"
		tar -xf "${txz}" -C "${tmpdir}"
		eend ${?}
	done
	eoutdent

	local dest="/tmp/rust-${version}-${target}"
	einfo "Repacking to ${dest}.tar.xz"
	rm -rf -- "${dest}"
	rm -rf -- "${dest}.tar"
	rm -rf -- "${dest}.tar.xz"

	local component
	for component in "${components[@]}"; do
		# need trailing slashes on both args
		einfo "Adding ${component}"
		# rust-std component and dir name don't match, adjust on the fly without mutating array
		rsync -a \
			"${tmpdir}/${component/rust-std-${target}/rust-std}-${version}-${target}/" \
			"${dest}/"
	done

	local compfile
	printf -v compfile '%s\n' "${components[@]}"
	einfo "Recording installer components:"
	echo "${compfile}"
	echo "${compfile}" > "${dest}/components"

	einfo "Compressing"

	# this keeps names in expected format
	# uses options from https://reproducible-builds.org/docs/archives/
	cd /tmp
	tar --mtime="@0" --sort=name --owner 0 --group 0 --numeric-owner \
		--pax-option="exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime" \
		-cf "${dest}".tar "$(basename ${dest})"
	xz -9 -T 0 "${dest}".tar
	file "${dest}".tar.xz
	mv "${dest}".tar.xz "${OUTPUT_DIR}/${dest}.tar.xz"

	ebegin "Nuking ${tmpdir} and temp files"
	rm -rf -- "${tmpdir}"
	rm -rf -- "${dest}"
	rm -rf -- "${dest}".tar
	eend ${?}
}

main "${@}"
