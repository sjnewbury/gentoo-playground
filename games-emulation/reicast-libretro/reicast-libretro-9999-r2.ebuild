# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit libretro-core

DESCRIPTION="libretro implementation of Reicast (Dreamcast)"
HOMEPAGE="https://github.com/libretro/reicast-libretro"
SRC_URI=""

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="git://github.com/libretro/reicast-emulator.git"
	KEYWORDS=""
else
	KEYWORDS="amd64 x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND="media-libs/mesa:0="
RDEPEND="${DEPEND}"

src_compile() {
	#this one could get some love from arm owners
	myemakeargs=(
		$(usex amd64 "WITH_DYNAREC=x86_64" "")
		$(usex x86 "WITH_DYNAREC=x86" "")
		$(usex arm "platform=rpi WITH_DYNAREC=arm" "")
		$(usex arm64 "platform=rpi WITH_DYNAREC=arm" "")
		"GLES=0"
		"NO_THREADS=0"
		"NO_JIT=0"
		"DEBUG=0"
	)
	emake "${myemakeargs[@]}" || die "emake failed"
}
