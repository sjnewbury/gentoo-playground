# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

if [[ ${PV} == 9999* ]]; then
AUTOTOOLS_AUTORECONF=1
EGIT_REPO_URI="https://gitlab.com/patrakov/dcaenc.git"
else
SRC_URI="http://aepatrakov.narod.ru/olderfiles/1/${P}.tar.gz"
KEYWORDS="~amd64 ~x86"
fi
inherit autotools-multilib git-r3

DESCRIPTION="DTS Coherent Acoustics audio encoder"
HOMEPAGE="http://aepatrakov.narod.ru/index/0-2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="alsa"

RDEPEND="alsa? ( media-libs/alsa-lib[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}"

ECONF_SOURCE=${S}

multilib_src_configure() {
	econf \
		$(use_enable alsa)
}
