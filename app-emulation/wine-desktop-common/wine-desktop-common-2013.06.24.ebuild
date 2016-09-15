# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit gnome2-utils

MY_PN=${PN%-*-*}-gentoo
MY_P=${MY_PN}-${PV}

DESCRIPTION="Various desktop menu items and icons for wine"
HOMEPAGE="http://dev.gentoo.org/~tetromino/distfiles/wine
	http://bazaar.launchpad.net/~ubuntu-wine/wine/ubuntu-debian-dir/files/head:/debian/"
SRC_URI="http://dev.gentoo.org/~tetromino/distfiles/${PN%-*-*}/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64" # ~x86 ~x86-fbsd
IUSE=""

RDEPEND="!app-emulation/wine:0[-multislot(-)]"
PDEPEND="app-eselect/eselect-wine"

# These use a non-standard "Wine" category, which is provided by
# /etc/xdg/applications-merged/wine.menu
QA_DESKTOP_FILE="usr/share/applications/wine-browsedrive.desktop
usr/share/applications/wine-notepad.desktop
usr/share/applications/wine-uninstaller.desktop
usr/share/applications/wine-winecfg.desktop"

S=${WORKDIR}/${MY_P}

src_install() {
	emake install DESTDIR="${D}" EPREFIX="${EPREFIX}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
