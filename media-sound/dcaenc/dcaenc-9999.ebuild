# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal
if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI="https://gitlab.com/patrakov/dcaenc.git"
	inherit git-r3

else
	SRC_URI="http://aepatrakov.narod.ru/olderfiles/1/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="DTS Coherent Acoustics audio encoder"
HOMEPAGE="http://aepatrakov.narod.ru/index/0-2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="alsa"

RDEPEND="alsa? ( media-libs/alsa-lib[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}"

ECONF_SOURCE=${S}

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	econf \
		$(use_enable alsa)
}
