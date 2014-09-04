# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/cpupower/cpupower-3.13.ebuild,v 1.2 2014/02/18 07:33:27 ssuominen Exp $

EAPI=5

MY_PV=${PV/_/-}

inherit systemd

DESCRIPTION="AMD K10/K11 P-State, frequency and voltage modification utility"
HOMEPAGE="https://code.google.com/p/turionpowercontrol/"
SRC_URI="https://turionpowercontrol.googlecode.com/files/tpc-${MY_PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="sys-libs/ncurses"

S="${WORKDIR}/tpc-${MY_PV}/src"

src_compile() {
	emake \
		CC=$(tc-getCC) \
		LIBS="$( $(tc-getPKG_CONFIG) --libs ncurses )"
}

src_install() {
	exeinto /usr/bin
	doexe TurionPowerControl
	dosym TurionPowerControl /usr/bin/tpc

	dodoc ../doc/*
	insinto /etc
	newins ../bin/Ubuntu-amd64/example.cfg tpc.conf
		
	systemd_dounit "${FILESDIR}"/tpc.service
}
