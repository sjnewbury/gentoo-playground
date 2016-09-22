# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-action/chromium-bsu/chromium-bsu-0.9.15.1.ebuild,v 1.4 2013/09/05 19:22:39 ago Exp $

EAPI=5
inherit autotools eutils gnome2-utils games git-r3

DESCRIPTION="Chromium B.S.U. - an arcade game"
HOMEPAGE="http://chromium-bsu.sourceforge.net/"
#SRC_URI="mirror://sourceforge/chromium-bsu/${P}.tar.gz"
EGIT_REPO_URI=git://git.code.sf.net/p/chromium-bsu/code
LICENSE="Clarified-Artistic"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="mixer nls +sdl2"

RDEPEND="media-fonts/dejavu
	media-libs/quesoglc
	media-libs/glpng
	virtual/opengl
	virtual/glu
	x11-libs/libXmu
	mixer? ( media-libs/sdl2-mixer )
	!mixer? (
		media-libs/freealut
		media-libs/openal
	)
	nls? ( virtual/libintl )
	sdl2? (
		media-libs/libsdl2
		media-libs/sdl2-image[png]
	)
	!sdl2? ( media-libs/freeglut )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_prepare() {
	default
	epatch "${FILESDIR}/SDL2-GL-libs.diff"
	epatch "${FILESDIR}/0001-Revert-Rename-the-icon-after-install-instead-of-copy.patch"
	eautoreconf
}

src_configure() {
	egamesconf \
		--disable-ftgl \
		--enable-glc \
		--disable-sdl \
		--disable-sdlmixer \
		--disable-sdlimage \
		$(use_enable mixer sdl2mixer) \
		$(use_enable !mixer openal) \
		$(use_enable nls) \
		$(use_enable sdl2) \
		$(use_enable sdl2 sdl2image) \
		$(use_enable !sdl2 glut)
}

src_install() {
	emake DESTDIR="${D}" install

	# remove installed /usr/games/share stuff
	rm -rf "${D}"/"${GAMES_PREFIX}"/share/

	newicon -s 64 misc/${PN}.png ${PN}.png
	domenu misc/chromium-bsu.desktop

	# install documentation
	dodoc AUTHORS README NEWS
	dohtml "${S}"/data/doc/*.htm*
	dohtml -r "${S}"/data/doc/images

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
