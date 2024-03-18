# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Command Line and GUI based MIDI Player"
HOMEPAGE="https://sourceforge.net/projects/playmidi/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc sparc x86"
IUSE="X"
#svga 

RDEPEND="sys-libs/ncurses
	X? ( x11-libs/libX11
		x11-libs/libSM
		x11-libs/libXaw )"
#	svga? ( media-libs/svgalib )
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )"

S="${WORKDIR}/${P/2.5/2.4}"

src_prepare() {
	eapply "${FILESDIR}"/${P}.patch
	eapply "${FILESDIR}"/CAN-2005-0020.patch
	eapply "${FILESDIR}"/${P}-includes.patch
	eapply "${FILESDIR}"/${P}-disable-svga-gtk.patch
	eapply "${FILESDIR}"/${P}-ticks.patch

	default

	rm -f io_svgalib.c io_gtk.c

	sed -i -e "s/@LIBDIR@/$(get_libdir)/g" Makefile || die sed1 failed

	sed -i -e 's/<linux\/\(awe_voice\.h\)>/\"\1\"/g' \
		playmidi.h-dist || die sed2 failed
}

src_compile() {
	local targets="playmidi"

	#use svga && targets="$targets splaymidi"
	use X && targets="$targets xplaymidi"

	echo "5" | ./Configure

	emake -j1 CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
		depend clean || die "emake failed."
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS} -I." LDFLAGS="${LDFLAGS}" ${targets} \
		|| die "emake failed."
}

src_install() {
	dobin playmidi
#	use svga && dobin splaymidi
	use X && dobin xplaymidi
	dodoc BUGS QuickStart README.1ST
	docinto techref
	dodoc techref/*
}
