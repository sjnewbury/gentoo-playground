# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit libretro-core

DESCRIPTION="libretro implementation of bNES/higan. (Nintendo Entertainment System)"
HOMEPAGE="https://github.com/libretro/bnes-libretro"
SRC_URI=""

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/libretro/bnes-libretro.git"
	KEYWORDS=""
else
	KEYWORDS="amd64 x86"
fi

LICENSE="GPL-3"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}
		games-emulation/libretro-info"

src_prepare() {
	epatch "${FILESDIR}"/gentoo-cflags.patch
	default
}

src_install() {
	LIBRETRO_LIB_DIR="${EROOT}usr/$(get_libdir)/libretro"
	insinto "${LIBRETRO_LIB_DIR}"
	doins "${PN/-libretro/_libretro.so}"
	libretro-core_src_install
}
