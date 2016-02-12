# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 autotools

DESCRIPTION="BBC Micro and Master 128 emulator."
HOMEPAGE=http://www.mkw.me.uk/beebem/
EGIT_REPO_URI=https://github.com/bmcollier/beebem.git

SLOT=0

DEPEND="media-libs/libsdl
	x11-libs/gtk+:2
	sys-libs/zlib"

src_prepare() {
	eautoreconf
}
