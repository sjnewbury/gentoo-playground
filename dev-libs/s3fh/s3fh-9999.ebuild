# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic git-r3

DESCRIPTION="SoftFloat-3a for Hercules. This is a modification of Dr. John Hauser’s SoftFloat-3a package."
HOMEPAGE="http://www.hercules-390.eu/"
#SRC_URI="http://downloads.hercules-390.eu/${P}.tar.gz"
EGIT_REPO_URI=https://github.com/hercules-390/SoftFloat-3a.git
LICENSE="QPL-1.0"
SLOT="0"
KEYWORDS=""
IUSE="bzip2 custom-cflags"

RDEPEND="bzip2? ( app-arch/bzip2 )
	sys-libs/zlib"
DEPEND="${RDEPEND}"

src_unpack() {
	git-r3_src_unpack
}

src_prepare() {
	cmake_src_prepare
	# Don't produce fatal error on "Gentoo" BUILD_TYPE
	sed -i -e '/^[[:space:]]*message([[:space:]]FATAL_ERROR.*BUILD_TYPE.*)/{s/^/#IGNORE /g}' CMakeLists.txt
}

src_configure() {
	use custom-cflags || strip-flags

	local mycmakeargs=(
		-DBUILD_TYPE=Gentoo
		-DINSTALL_PREFIX="${EPREFIX}/usr"
		-DCCKD-BZIP2="$(usex bzip2)"
		-DHET-BZIP2="$(usex bzip2)"
		-DCUSTOM="Gentoo ${PF}.ebuild"
		-DOPTIMIZATION="${CFLAGS}"
	)
	cmake_src_configure
}

src_install() {
	default
	cmake_src_install
	# clean up install breakage
	rm -rf "${D}"/var

	insinto /usr/share/SoftFloat-3a
	cd "${S}"
	dodoc README.*
}
