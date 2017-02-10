# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib systemd

DESCRIPTION="Daemon that locks files into memory"
HOMEPAGE="http://doc.coker.com.au/projects/memlockd/"
SRC_URI="http://www.coker.com.au/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	default

	# Gentoo has two different x86 multilib standards,
	# other multilib ABIs, static patching won't work,
	# so be clever...
	sed -e '/i386/d' \
	    -i memlockd.cfg
	for this_abi in ${MULTILIB_ABIS}; do
	sed	-e "s/\(.*\)\/lib\/x86_64-linux-gnu\/\(.*\)/&\n\1\/$(get_abi_var LIBDIR ${this_abi})\/\2/" \
		-i memlockd.cfg || die 'sed cfg failed'
	done
	sed -e '/x86_64/d' \
	    -i memlockd.cfg
}

src_install() {
	doman memlockd.8
	newdoc changes.txt ChangeLog

	insinto /etc/
	doins memlockd.cfg
	dodir /etc/memlockd.d
	insinto /etc/memlockd.d
	doins ${FILESDIR}/memlockd.d/*

	dosbin memlockd

	doinitd "${FILESDIR}"/${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
}
