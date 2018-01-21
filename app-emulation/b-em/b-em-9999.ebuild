# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3 autotools flag-o-matic

DESCRIPTION="B-em is an attempt to emulate a BBC Micro, made by Acorn Computers in the 80s."
HOMEPAGE=
EGIT_REPO_URI=https://github.com/stardot/b-em.git

SLOT=0

DEPEND="media-libs/allegro:0
	media-libs/openal
	media-libs/freealut
	sys-libs/zlib"

src_prepare() {
	default

	# allegro-config test fails otherwise
	append-flags -Wno-error=unused-result

	# multi if conditionals per line confuses gcc
	append-flags -Wno-error=misleading-indentation

	# oldpc is defined as 32bit for x86 and 16bit for 6502
	filter-flags -flto*

	AT_M4DIR=. eautoreconf
}
