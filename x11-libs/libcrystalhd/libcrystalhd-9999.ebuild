# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
EAPI=5

[[ ${PV} = *9999* ]] && VCS_ECLASS="git-2" || VCS_ECLASS=""

inherit eutils autotools ${VCS_ECLASS}

DESCRIPTION="CrystalHD lib"
HOMEPAGE=""
#EGIT_REPO_URI="git://git.linuxtv.org/jarod/crystalhd.git"
EGIT_REPO_URI="https://github.com/agx/libcrystalhd.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_prepare() {
#	epatch ${FILESDIR}/"${P}"-flags.patch

	eautoreconf
}	

src_compile() {
	cd linux_lib/libcrystalhd
	emake
}

src_install() {
	cd linux_lib/libcrystalhd
	emake install DESTDIR="${D}"
}
