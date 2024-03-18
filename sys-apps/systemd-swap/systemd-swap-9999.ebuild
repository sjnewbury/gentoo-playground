# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

EGIT_REPO_URI="https://github.com/Nefelim4ag/systemd-swap.git"

inherit systemd git-r3

DESCRIPTION="systemd support for swap deviceds"
HOMEPAGE="https://github.com/Nefelim4ag/systemd-swap"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sys-apps/systemd
	dev-python/python-systemd
"
RDEPEND="${DEPEND}"

#PATCHES=("${FILESDIR}/fix-unbound-variables.patch")

src_compile() {
	emake swap.conf
}

src_install() {
	emake exec_prefix= PATCH=true DESTDIR=${D} install
	keepdir /var/lib/systemd-swap
}
