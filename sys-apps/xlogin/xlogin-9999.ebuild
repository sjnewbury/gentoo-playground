# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=5

inherit systemd git-r3

DESCRIPTION="Automatic X login service for systemd"
HOMEPAGE="https://github.com/joukewitteveen/xlogin"
SRC_URI=""
EGIT_REPO_URI="https://github.com/joukewitteveen/xlogin.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND="x11-base/xorg-server
	>=sys-apps/systemd-208"
DEPEND="sys-apps/sed"

src_prepare() {
	# Upstream expects to find /usr/bin/bash, use /bin/sh instead
	sed -i -e 's:/usr/bin/bash:/bin/sh:' "${S}"/* \
		|| die "Failed to fix shell location"
}

src_compile() {
	# Makefile installs files by default
	:
}

src_install() {
	insinto /etc/X11/xinit/xinitrc.d
	doins 25-xlogin	
	exeinto /usr/bin
	doexe x-daemon
	systemd_dounit {x@,xlogin@}.service
}
