# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_IN_SOURCE_BUILD=1

inherit cmake

DESCRIPTION="Cinder is a peer-reviewed, free, open source C++ library for creative coding."
HOMEPAGE="https://github.com/${PN}/${PN^}"
SRC_URI="https://github.com/${PN}/${PN^}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Cinder"
SLOT="0/${PV}"
KEYWORDS="amd64 ~arm ~hppa ~ppc ~ppc64 ~sparc x86"
IUSE="debug"

S=${WORKDIR}/${PN^}-${PV}

#PATCHES=( "${FILESDIR}"/system-install.patch )

DEPEND="
	>=dev-libs/boost-1.54:=[nls]
	"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
	)
	cmake_src_configure
}
