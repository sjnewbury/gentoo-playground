# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit gnome2 autotools games git-r3

SRC_URI=
EGIT_REPO_URI=git://git.gnome.org/gnome-video-arcade

DESCRIPTION="A simple MAME front-end for the GNOME Desktop Environment"
HOMEPAGE="http://mbarnes.github.com/gnome-video-arcade/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome"

RDEPEND="gnome? ( >=gnome-base/libgnomeui-2.14.0 )
	>=dev-libs/glib-2.14.0
	>=x11-libs/gtk+-2.12.0:2
	>=gnome-base/libglade-2.6.0
	>=x11-themes/gnome-icon-theme-2.18.0
	>=dev-db/sqlite-3.0.0
	>=x11-libs/libwnck-2.16
	gnome-base/gconf
	|| ( games-emulation/sdlmame games-emulation/xmame )"
DEPEND="${RDEPEND}
	app-text/scrollkeeper
	app-text/gnome-doc-utils
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog NEWS README"

src_prepare() {
	gnome2_src_prepare
	cd "${S}"

	# change search patch to include /usr/games/bin
	sed 	-e "s:\(sdlmame\):\1 mame64:g" \
		-e "s:/usr/games:${GAMES_BINDIR}:g" \
		-i configure.ac || die "sed failed"

	eautoreconf
}

src_compile() {
	local MY_USE
	use gnome || MY_USE="--without-gnome"

	gnome2_src_compile --bindir="${GAMES_BINDIR}" ${MY_USE} || die "compile failed"
}

src_install() {
	gnome2_src_install || die "install failed"
	prepgamesdirs
}
