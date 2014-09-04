# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/aiccu/aiccu-2007.01.15-r4.ebuild,v 1.7 2013/09/06 18:35:35 ago Exp $

EAPI=5

inherit systemd git-r3

DESCRIPTION="RTSP Server"
HOMEPAGE="https://github.com/revmischa/rtsp-server"
SRC_URI=""
EGIT_REPO_URI="https://github.com/revmischa/rtsp-server.git"

LICENSE="SixXS"
SLOT="0"
KEYWORDS="amd64 arm hppa ppc sparc x86"
IUSE="systemd"

RDEPEND="net-libs/gnutls
	sys-apps/iproute2
	systemd? ( sys-apps/systemd )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${P}

CONFIG_CHECK="~TUN"

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-r2-init.gentoo.patch \
		"${FILESDIR}"/${P}-Makefile.patch \
		"${FILESDIR}"/${P}-setupscript.patch \
		"${FILESDIR}"/${P}-uclibc.patch \
		"${FILESDIR}"/${P}-systemd.patch
}

src_compile() {
	# Don't use main Makefile since it requires additional
	# dependencies which are useless for us.
	emake CC=$(tc-getCC) STRIP= -C unix-console \
		HAVE_SYSTEMD=$(usex systemd 1 0)
}

src_install() {
	dosbin unix-console/${PN}

	insopts -m 600
	insinto /etc
	doins doc/${PN}.conf
	newinitd doc/${PN}.init.gentoo ${PN}

	use systemd && systemd_dounit doc/${PN}.service

	dodoc doc/{HOWTO,README,changelog}
}
