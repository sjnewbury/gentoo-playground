# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-nds/rpcbind/rpcbind-0.2.0.ebuild,v 1.11 2011/09/02 20:10:55 vapier Exp $

EAPI="4"

FEDORA_T=development
FEDORA_DR=21
FEDORA_V="${PV}-0.1.fc${FEDORA_DR}"
RPCBUSR=rpc
RPCBGRP=rpc
RPCBDIR=/var/lib/rpcbind

inherit user autotools rpm systemd
if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://git.infradead.org/~steved/rpcbind.git"
	inherit autotools git
	SRC_URI=""
	#KEYWORDS=""
else
	SRC_URI="http://download.fedoraproject.org/pub/fedora/linux/${FEDORA_T}/rawhide/source/SRPMS/r/${PN}-${FEDORA_V}.src.rpm"
	KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86"
fi

DESCRIPTION="portmap replacement which supports RPC over various protocols"
HOMEPAGE="http://sourceforge.net/projects/rpcbind/"

LICENSE="BSD"
SLOT="0"
IUSE="tcpwrapper systemd"

RDEPEND="net-libs/libtirpc
	tcpwrapper? ( sys-apps/tcp-wrappers )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	enewgroup ${RPCBGRP} 32 || die "Failed to create ${RPCBGRP} group"
	enewuser ${RPCBUSR} 32 -1 /dev/null ${RPCBUSR}  || die "Failed to create ${RPCBUSR} user"
}

src_prepare() {
	if [[ ${PV} == "9999" ]] ; then
		eautoreconf
	else
		#epatch "${FILESDIR}"/${P}-pkgconfig.patch
		for FEDORA_PATCH in "${WORKDIR}"/*.patch; do
			epatch "${FEDORA_PATCH}"
		done
		eautoreconf
	fi

	# Use gentoo service environment location
	sed -i -e 's/sysconfig/conf\.d/g' "${WORKDIR}"/*.service || die
}

src_configure() {
	econf 	--bindir=/sbin \
		--with-statedir="$RPCBDIR" \
		--with-rpcuser="$RPCBUSR" \
		--enable-warmstarts \
		$(use_enable tcpwrapper libwrap)
}

src_install() {
	emake DESTDIR="${D}" install || die
	doman man/rpc{bind,info}.8
	dodoc AUTHORS ChangeLog NEWS README
	newinitd "${FILESDIR}"/rpcbind.initd rpcbind || die
	newconfd "${FILESDIR}"/rpcbind.confd rpcbind || die

	dodir "${RPCBDIR}"
	chown -R ${RPCBUSR}:${RPCBGRP} "${D}"/"${RPCBDIR}"
	systemd_dounit "${WORKDIR}"/*.service
	systemd_dounit "${WORKDIR}"/*.socket
}
