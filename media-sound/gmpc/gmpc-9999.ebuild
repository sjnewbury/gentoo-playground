# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/gmpc/gmpc-11.8.16-r1.ebuild,v 1.1 2014/06/27 16:16:01 angelos Exp $

EAPI=7
VALA_MIN_API_VERSION=0.12

inherit autotools gnome2-utils vala git-r3

DESCRIPTION="A GTK+3 client for the Music Player Daemon"
HOMEPAGE="http://gmpc.wikia.com/wiki/Gnome_Music_Player_Client"
#SRC_URI="http://download.sarine.nl/Programs/gmpc/11.8/${P}.tar.gz"
EGIT_REPO_URI=https://github.com/DaveDavenport/gmpc.git

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="nls xspf +unique"

RDEPEND="dev-db/sqlite:3
	>=dev-libs/glib-2.16:2
	dev-libs/libxml2:2
	>=media-libs/libmpd-11.8.90
	net-libs/libsoup:2.4
	>=x11-libs/gtk+-3.0:3
	x11-libs/libX11
	x11-themes/hicolor-icon-theme
	unique? ( dev-libs/libunique:1 )
	xspf? ( >=media-libs/libxspf-1.2 )
	media-libs/glyr"
DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/gnome-doc-utils
	>=dev-util/gob-2.0.17
	virtual/pkgconfig
	nls? ( dev-util/intltool
		sys-devel/gettext )"

DOCS=( AUTHORS README )

pkg_setup() {
	export MAKEOPTS=-j1
}

src_prepare() {
	sed -i -e "s:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:" configure.ac || die
	eautoreconf
	vala_src_prepare
}

src_configure() {
	econf \
		--disable-static \
		--disable-libspiff \
		--disable-appindicator \
		--enable-mmkeys \
		$(use_enable nls) \
		$(use_enable unique) \
		$(use_enable xspf libxspf)
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
