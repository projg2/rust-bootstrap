#!/bin/bash -e

read -p "Enter version (\${PVR}): " PVR
read -p "Enter ebuild commit id: " EBUILD_COMMIT_ID

: ${PVR?:"Version is required."} ${EBUILD_COMMIT_ID?:"Ebuild commit id is required."}

EBUILD_SHA256=$(curl "https://raw.githubusercontent.com/gentoo/gentoo/${EBUILD_COMMIT_ID}/dev-lang/rust/rust-${PVR}.ebuild" | sha256sum | cut -d' ' -f1)
echo "Ebuild SHA256: ${EBUILD_SHA256}"

port=$((RANDOM % 10000 + 40000))

echo "On devbox, run 'systemd-run --user timeout 10m python -m http.server ${port} -d /home/arthurzam/rust-bin' to serve the files"
read -p "Press ENTER to continue"


wget --recursive "http://devbox.amd64.dev.gentoo.org:${port}/"
cd "devbox.amd64.dev.gentoo.org:${port}"
sha512sum "rust-${PVR}"-*.tar.xz > "../rust-${PVR}-SHA512SUMS.asc"
cd ..

if [[ $(git --no-pager tag -l ${PVR}) ]]; then
	echo "Tag ${PVR} already exists."
else
	echo "Creating tag ${PVR}."
	git add "rust-${PVR}-SHA512SUMS.asc"
	git commit --signoff --gpg-sign --file=- <<- EOF
		rust-${PVR}

		Based on https://github.com/gentoo/gentoo/blob/${EBUILD_COMMIT_ID}/dev-lang/rust/rust-${PVR}.ebuild

		ebuild sha256: ${EBUILD_SHA256}
	EOF
	git tag --sign "${PVR}" --message="${PVR}"
	git push --atomic origin master "${PVR}"
fi

gh release create --draft --notes-file - --verify-tag --title "${PVR}" "${PVR}" "devbox.amd64.dev.gentoo.org:${port}/rust-${PVR}"-*.tar.xz <<- EOF
Based on https://github.com/gentoo/gentoo/blob/${EBUILD_COMMIT_ID}/dev-lang/rust/rust-${PVR}.ebuild

ebuild sha256: \`${EBUILD_SHA256}\`

SHA512SUM:
\`\`\`
$(cat rust-${PVR}-SHA512SUMS.asc)\`\`\`
EOF
