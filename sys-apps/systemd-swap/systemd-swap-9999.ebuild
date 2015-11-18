# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="https://github.com/Nefelim4ag/systemd-swap.git"

inherit systemd git-r3

DESCRIPTION="systemd support for swap deviceds"
HOMEPAGE="https://github.com/Nefelim4ag/systemd-swap"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-apps/systemd"
RDEPEND="${DEPEND}"

src_install() {
	exeinto /usr/lib/systemd/scripts
	doexe systemd-swap.sh
    insinto /etc
    doins systemd-swap.conf
    insinto /etc/modprobe.d
    doins 90-systemd-swap.conf
    systemd_dounit systemd-swap.service
}
