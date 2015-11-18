# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit git-r3

DESCRIPTION="Drop Down Terminal extension for the Gnome Shell"
HOMEPAGE="https://extensions.gnome.org/extension/442/drop-down-terminal/"
#SRC_URI=""
EGIT_REPO_URI=https://github.com/zzrough/gs-extensions-drop-down-terminal

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	app-eselect/eselect-gnome-shell-extensions
	>=gnome-base/gnome-shell-3.14
"
DEPEND="app-arch/xz-utils"

#S="${WORKDIR}/gnome-shell-extensions-drop-down-terminal-${PV}"

src_install() {
	local uuid='drop-down-terminal@gs-extensions.zzrough.org'
	insinto "/usr/share/gnome-shell/extensions/${uuid}"
	doins ${uuid}/*
}

pkg_postinst() {
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}
