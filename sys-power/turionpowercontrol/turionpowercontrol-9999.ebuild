# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/cpupower/cpupower-3.13.ebuild,v 1.2 2014/02/18 07:33:27 ssuominen Exp $

EAPI=6

MY_PV=${PV/_/-}

inherit systemd eutils git-r3

DESCRIPTION="AMD K10/K11 P-State, frequency and voltage modification utility"
HOMEPAGE="https://code.google.com/p/turionpowercontrol/"
SRC_URI=
EGIT_REPO_URI=https://github.com/turionpowercontrol/tpc.git

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="sys-libs/ncurses"

#S="${WORKDIR}/tpc-${MY_PV}"

PATCHES=(
	"${FILESDIR}/tpc-0.44-remove-MSVC_Round.patch"
)

src_compile() {
	cd src
	emake \
		CC=$(tc-getCC) \
		LIBS="$( $(tc-getPKG_CONFIG) --libs ncurses )"
}

src_install() {
	exeinto /usr/bin
	doexe TurionPowerControl
	dosym TurionPowerControl /usr/bin/tpc

	dodoc doc/*
	insinto /etc

	systemd_dounit "${FILESDIR}"/tpc.service
}
