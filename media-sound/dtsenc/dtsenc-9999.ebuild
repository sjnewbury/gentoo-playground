# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/aacplusenc/aacplusenc-0.17.5.ebuild,v 1.2 2011/12/04 22:53:46 radhermit Exp $

EAPI=5
inherit autotools git-r3 multilib-minimal

DESCRIPTION="DCA/DTS Encoder"
HOMEPAGE="http://gitorious.org/dtsenc"
SRC_URI=""
EGIT_REPO_URI="git://gitorious.org/dtsenc/dtsenc.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="alsa"

RDEPEND="alsa? ( media-libs/alsa-lib )"
DEPEND="${RDEPEND}"

ECONF_SOURCE=${S}

src_prepare() {
	#epatch "${FILESDIR}/0001-Revert-Wrap-ALSA-plugin-output-into-IEC-61937-5-fram.patch"
	eautoreconf
}

multilib_src_configure() {
	econf \
		$(use_enable alsa)
}
