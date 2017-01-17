# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools gnome2

DESCRIPTION="gnome-shell extension for connman."
HOMEPAGE="https://extensions.gnome.org/extension/981/connman-extension/"
SRC_URI="https://github.com/jgke/gnome-extension-connman/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	app-eselect/eselect-gnome-shell-extensions
	=gnome-base/gnome-shell-3.22*:=
"
DEPEND="
	gnome-base/gnome-common
	net-misc/connman-gtk
"

S="${WORKDIR}/${P/shell-extensions/extension}"

src_prepare() {
	default
	eautoreconf
	sed -i 's/"3.16"/"3.22"/g' \
		src/metadata.json.in || die
}

src_install() {
	# install is racy
	emake -j1 DESTDIR="${D}" install
}

pkg_postinst() {
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}
