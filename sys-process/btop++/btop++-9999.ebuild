# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Linux/OSX/FreeBSD resource monitor"
HOMEPAGE="https://github.com/aristocratos/btop"

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI=https://github.com/aristocratos/btop
else
	SRC_URI="https://github.com/aristocratos/${PN/++}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~riscv ~x86"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="test"

RDEPEND="
	>=dev-python/psutil-5.7.1
"

src_compile() {
	emake OPTFLAGS="${CFLAGS}" PREFIX=/usr
}

src_install() {
	emake PREFIX=/usr DESTDIR="${D}" install
}
