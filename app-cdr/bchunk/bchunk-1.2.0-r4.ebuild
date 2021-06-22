# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit flag-o-matic

DESCRIPTION="Convert CD images from bin/cue to iso+wav/cdr"
HOMEPAGE="http://he.fi/bchunk/"
SRC_URI="${HOMEPAGE}${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DOCS=( "${P}.lsm" "${PN}.spec" README ChangeLog )
PATCHES=( "${FILESDIR}/CVE-2017-15953.patch" "${FILESDIR}/CVE-2017-15955.patch" )

src_prepare() {
	default

	# Lets make sure our CFLAGS are used and LTO isn't broken
	sed -i \
		-e "s/^\(CC =\).*$/\1 $(tc-getCC)/" \
		-e "s/^\(LD =\).*$/\1 $(tc-getCC)/" \
		-e "/^CFLAGS =/s/^/#/" \
		Makefile
}

src_install() {
	dobin "${PN}"
	doman "${PN}.1"
	einstalldocs
}
