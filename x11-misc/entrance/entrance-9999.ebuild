# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit autotools eutils git-2 pam

DESCRIPTION="Display-manager based on efl"
HOMEPAGE="http://www.enlightenment.org/"
SRC_URI=""
EGIT_REPO_URI="http://git.enlightenment.org/misc/entrance.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="consolekit vkbd grub pam systemd"

RDEPEND="
	>=dev-libs/efl-1.17[systemd?]
	app-admin/sudo
	sys-apps/dbus
	x11-libs/libxcb
	consolekit? ( sys-auth/consolekit )
	pam? ( sys-libs/pam )
	vkbd? ( x11-plugins/ekbd )"
DEPEND="${RDEPEND}
	!<sys-apps/systemd-192
	virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# if efreetd isn't already running it gets spawned as root with
	# default XDG_RUNTIME_DIR for example: /run/user/0
	export XDG_RUNTIME_DIR="${T}"

	local config=(
		$(use_enable consolekit)
		$(use_enable vkbd ekbd)
		$(use_enable grub grub2)
		$(use_enable pam)
		$(use_enable systemd)
	)

	econf "${config[@]}"
}

src_install() {
	default
	newpamd "${FILESDIR}"/entrance.pamd entrance
}
