# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EGIT_REPO_URI="https://github.com/0ad/0ad.git"
if [[ ${PV} == 9999* ]]; then
	GIT_ECLASS="git-r3"
fi

inherit games ${GIT_ECLASS}

MY_P=0ad-${PV/_/-}
DESCRIPTION="Data files for 0ad"
HOMEPAGE="http://wildfiregames.com/0ad/"

if [[ ${PV} == 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="mirror://sourceforge/zero-ad/${MY_P}-unix-data.tar.xz"
fi

LICENSE="GPL-2 CC-BY-SA-3.0 LPPL-1.3c BitstreamVera"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="~games-strategy/0ad-${PV}[nvtt]"


S=${WORKDIR}/${MY_P}
EGIT_CHECKOUT_DIR=${S}

src_prepare() {
	default
	#epatch "${FILESDIR}/${P/-data}-GL4.patch"
	epatch "${FILESDIR}"/${P/-data}-gentoo.patch

	rm binaries/data/tools/fontbuilder/fonts/*.txt
	rm -fr binaries/data/l10n/
}

src_compile() {
	if [[ ${PV} == 9999* ]]; then

		# Based on dist/build.sh
		# This is the 0ad binary by another name
		PYROGENESIS=/usr/bin/pyrogenesis

		# Package the mod data
		${PYROGENESIS} -mod=mod \
			-archivebuild=binaries/data/mods/public \
			-archivebuild-output=binaries/data/mods/public/public.zip || die
		${PYROGENESIS} -archivebuild=binaries/data/mods/mod \
			-archivebuild-output=binaries/data/mods/mod/mod.zip || die
		rm -f binaries/data/config/dev.cfg
	fi
}

src_install() {
	insinto "${GAMES_DATADIR}"/0ad
	doins -r binaries/data/{config,tools}
	insinto "${GAMES_DATADIR}"/0ad/mods/mod
	doins binaries/data/mods/mod/mod.zip
	insinto "${GAMES_DATADIR}"/0ad/mods/public
	doins binaries/data/mods/public/public.zip
	prepgamesdirs
}
