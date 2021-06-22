# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils toolchain-funcs

MY_P="${P/-tools/}"
MY_PN="${PN/-tools/}"
DESCRIPTION="Compressed in-memory swap device for Linux"
HOMEPAGE="http://code.google.com/p/compcache/"
SRC_URI="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/${MY_PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}/sub-projects/rzscontrol"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.6_gentoo.patch"
}

src_compile() {
	tc-export CC
	default
}

src_install() {
	dobin rzscontrol || die
	doman man/rzscontrol.1 || die
}
