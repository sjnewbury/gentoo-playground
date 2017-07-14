# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils games git-r3

MY_PV=${PV//./}
DESCRIPTION=""
HOMEPAGE="http://www.alcyone.com/max/projects/omega/"
#SRC_URI=""
EGIT_REPO_URI=https://github.com/sjnewbury/omega-ng.git

LICENSE="LGPL"
SLOT="0"

IUSE="gzip center-on-player"

RDEPEND="gzip? ( app-arch/gzip )"

DEPEND="${RDEPEND}
	sys-libs/ncurses
	virtual/pkgconfig"

src_prepare() {
	sed	-e "/^#define OMEGALIB/s:\./lib/:${GAMES_DATADIR}/${PN}/:" \
		-e "/^#define OMEGASTATE/s:\./lib/:${GAMES_STATEDIR}/${PN}/:" \
		-i defs.h || die

	use gzip && ( sed -e "/^\/\*.*#define COMPRESS_SAVE_FILES/s/\/\*\(.*\)\*\//\1/" \
		-i defs.h || die )

	use center-on-player && ( sed -e "/^\/\*.*#define CENTER_ON_PLAYER/s/\/\*\(.*\)\*\//\1/" \
		-i defs.h || die )
}

src_install() {
	dobin omega
	dodir "${GAMES_DATADIR}/${PN}" || die
	dodir "${GAMES_STATEDIR}/${PN}" || die
	cp -a lib/* ${EROOT}${ED}/${GAMES_DATADIR}/${PN}/ || die
	mv ${EROOT}${ED}/${GAMES_DATADIR}/${PN}/omega.{hi,log} \
		${EROOT}${ED}/${GAMES_STATEDIR}/${PN}/	
	prepgamesdirs
	fperms g+w "${GAMES_STATEDIR}/${PN}"/omega.{hi,log}
	dodoc docs/*.txt
	doman docs/omega.6
}
