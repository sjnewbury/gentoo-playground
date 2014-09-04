# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="https://github.com/lemenkov/systemd-user-units.git"

inherit systemd git-r3

DESCRIPTION="A collection of units for the systemd user session"
HOMEPAGE="https://github.com/lemenkov/systemd-user-units"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-apps/systemd
	sys-apps/xorg-launch-helper
	sys-apps/sed"
RDEPEND="${DEPEND}"

src_install() {
	# Provided by sys-apps/user-session-units
	rm -f ${S}/user/dbus.service
	rm -f ${S}/user/dbus.socket
	insinto "$(systemd_get_userunitdir)"
	doins "${S}"/user/* "${D}"/"$(systemd_get_userunitdir)"
	insinto "$(systemd_get_userunitdir)"/default.target.wants
	doins "${S}"/user/default.target.wants/* "${D}"/"$(systemd_get_userunitdir)"/default.target.wants
}
