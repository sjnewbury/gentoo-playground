# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit libretro-core

DESCRIPTION="libretro implementation of mupen64plus for Vulkan (Nintendo64)"
HOMEPAGE="https://github.com/libretro/mupen64plus-libretro"
SRC_URI=""

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="git://github.com/libretro/mupen64plus-libretro.git"
	KEYWORDS=""
else
	KEYWORDS="amd64 x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND="media-libs/mesa:0=[vulkan]"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	sed -i -e 's/-O2 -g//g' $(find -name 'Makefile*')
}

src_compile() {
	#this one could get some love from arm owners
	myemakeargs=(
		$(usex amd64 "WITH_DYNAREC=x86_64" "")
		$(usex x86 "WITH_DYNAREC=x86" "")
		$(usex arm "platform=rpi WITH_DYNAREC=arm" "")
		$(usex arm64 "platform=rpi WITH_DYNAREC=arm" "")
		"HAVE_VULKAN=1"
	)
	emake "${myemakeargs[@]}" || die "emake failed"
}
