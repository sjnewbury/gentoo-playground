# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit toolchain-funcs

DESCRIPTION="Header-file-only, JSON parser serializer in C++"
HOMEPAGE="https://github.com/kazuho/picojson"
if [[ ${PV} = 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/kazuho/picojson.git"
else
	SRC_URI="https://github.com/kazuho/picojson/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

PATCHES=("${FILESDIR}/${P}-noexcept.patch")

LICENSE="BSD-2"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_compile() {
	:
}

src_test() {
	tc-export CXX
	emake test
}

src_install() {
	emake DESTDIR="${D}" prefix="${EPREFIX}/usr" install
	dodoc README.mkdn Changes
}
