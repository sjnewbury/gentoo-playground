# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/ufo-ai/ufo-ai-2.4.ebuild,v 1.4 2012/11/04 06:02:12 mr_bones_ Exp $

EAPI=5
PYTHON_COMPAT=( pypy python{2_6,2_7} )

inherit eutils python-any-r1 flag-o-matic games git-2

MY_P=${P/o-a/oa}

DESCRIPTION="UFO: Alien Invasion - X-COM inspired strategy game"
HOMEPAGE="http://ufoai.sourceforge.net/"
#SRC_URI="mirror://sourceforge/ufoai/${MY_P}-source.tar.bz2
#	mirror://sourceforge/ufoai/${MY_P}-data.tar
#	http://mattn.ninex.info/1maps.pk3"
SRC_URI=
#EGIT_REPO_URI="git://git.code.sf.net/p/ufoai/code"
EGIT_REPO_URI="https://github.com/ufoai/ufoai.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc x86"
IUSE="debug dedicated editor sse +download-maps"

# Dependencies and more instructions can be found here:
# http://ufoai.ninex.info/wiki/index.php/Compile_for_Linux
DEPEND="!dedicated? (
		virtual/opengl
		virtual/glu
		media-libs/libsdl2
		media-libs/sdl2-image[jpeg,png]
		media-libs/sdl2-ttf
		media-libs/sdl2-mixer
		virtual/jpeg
		media-libs/libpng:0
		media-libs/libogg
		media-libs/libvorbis
		x11-proto/xf86vidmodeproto
	)
	net-misc/curl
	sys-devel/gettext
	sys-libs/zlib
	sys-apps/findutils
	net-misc/rsync
	dev-util/cunit
	editor? (
		dev-libs/libxml2
		virtual/jpeg
		media-libs/openal
		x11-libs/gtkglext
		x11-libs/gtksourceview:2.0
	)
	${PYTHON_REQUIRED_USE}
"

#S=${WORKDIR}/${MY_P}-source

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-bfd-package.patch


	if has_version '>=sys-libs/zlib-1.2.5.1-r1' ; then
		sed -i -e '1i#define OF(x) x' src/common/ioapi.h || die "sed 1 failed"
	fi

	# System version of lua is just called lua
	sed -i -e 's/lua5.1/lua/g' build/default.mk || die "sed 2 failed"

	if use download-maps; then
		einfo "Looking for existing installation..."
		if has_version "${CATEGORY}/${PN}"; then
			einfo "Found already installed version!"
			ebegin "Copying installed maps from "${GAMES_PREFIX_OPT}/${PN/-}"/maps"
			if [[ -d "${GAMES_PREFIX_OPT}/${PN/-}"/maps ]]; then
				cat <<EOT | rsync --progress -am \
					"${GAMES_PREFIX_OPT}/${PN/-}"/maps/ \
					"${S}"/base/maps/ --filter='. -'
+ */
+ *.bsp
- *
EOT
			eend $?
 			else
				ewarn "Failed to access existing maps! Probably access permissions.  Will download a new set."
			fi

		else
			einfo "Nope."
		fi
		${PYTHON} contrib/map-get/update.py
		if [[ "$?" -ne 0 ]]; then
			ewarn "Update failed! Forcing map compilation! (this will be SLOW)"
			FORCE_COMPILE=1
		fi
	fi

	# don't try to use the system mini-xml
	sed -i -e '/mxml/d' configure || die sed 3 failed

}

src_configure() {
	# they are special and provide hand batched configure file
	local myconf="
		--disable-dependency-tracking
		$(use_enable !debug release)
		$(use_enable editor uforadiant)
		$(use_enable sse)
		--enable-ufoded
		--bindir=${GAMES_BINDIR}
		--libdir=$(games_get_libdir)
		--datadir=${GAMES_DATADIR}/${PN/-}
		--localedir=${EPREFIX}/usr/share/locale/
		--prefix=${GAMES_PREFIX}"

	if ( use editor || ! use download-maps || [[ -n $FORCE_COMPILE ]] ); then
		myconf="${myconf}
		--enable-ufo2map"
	fi

	echo "./configure ${myconf}"
	./configure ${myconf} || die "configure script failed"
}

src_compile() {
	# Build ufo2map first otherwise parallel make fails
	emake ufo2map

	emake

	# Compile maps or pre-compiled
	if ( use download-maps && [[ -n $FORCE_COMPILE ]] ); then
		emake maps
	else
		einfo "Using pre-compiled maps"
	fi

	emake lang
	emake pk3

	if use editor; then
		emake uforadiant
	fi
}

src_install() {
	newicon src/ports/linux/ufo.png ${PN}.png || die
	dobin ufoded || die
	make_desktop_entry ufoded "UFO: Alien Invasion Server" ${PN}
	if ! use dedicated; then
		dobin ufo || die
		make_desktop_entry ufo "UFO: Alien Invasion" ${PN}
	fi

	if use editor; then
		dobin ufo2map ufomodel
	fi

	# install data
	insinto "${GAMES_DATADIR}"/${PN/-}
	doins -r base || die
	rm -rf "${ED}/${GAMES_DATADIR}/${PN/-}/base/game.so"
	dogameslib base/game.so

	# move translations where they belong
	dodir "${GAMES_DATADIR_BASE}/locale" || die
	mv "${ED}/${GAMES_DATADIR}/${PN/-}/base/i18n/"* \
		"${ED}/${GAMES_DATADIR_BASE}/locale/" || die
	rm -rf "${ED}/${GAMES_DATADIR}/${PN/-}/base/i18n/" || die

	# move maps and link them back so a later rebuild can use
	# them to save downloading a whole new pre-compiled set
	dodir ${GAMES_PREFIX_OPT}/${PN/-}
	mv "${ED}/${GAMES_DATADIR}/${PN/-}/base/maps" "${ED}/${GAMES_PREFIX_OPT}/${PN/-}"
	ln -s "${GAMES_PREFIX_OPT}/${PN/-}/maps" "${ED}/${GAMES_DATADIR}/${PN/-}/base/"

	prepgamesdirs

}

pkg_postinst() {
	ebegin "Allow \"other\" access to map directories"
	find "${ROOT}/${GAMES_PREFIX_OPT}/${PN/-}/maps" -type d -exec chmod o+rx '{}' \;
	eend $?
	ebegin "Allow \"other\" to read maps"
	find "${ROOT}/${GAMES_PREFIX_OPT}/${PN/-}/maps" -name '*.bsp' -exec chmod o+r '{}' \;
	eend $?
}
