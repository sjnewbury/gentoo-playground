# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

PYTHON_COMPAT=( python3_{9,10,11,12} )
DISTUTILS_USE_SETUPTOOLS=rdepend

# pypy unsupported for now due to dev-python/alembic ;-(

#if LIVE
#EGIT_REPO_URI="git://github.com/g2p/bedup.git
#	https://github.com/g2p/bedup.git"
EGIT_REPO_URI=https://github.com/saimonn/bedup.git

inherit git-r3
#endif

inherit distutils-r1 vcs-snapshot

DESCRIPTION="Btrfs file de-duplication tool"
HOMEPAGE="https://github.com/g2p/bedup"
SRC_URI="https://github.com/g2p/${PN}/archive/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="syscall"

# we need btrfs-progs with includes installed.
DEPEND=">=dev-python/cffi-0.5:=[${PYTHON_USEDEP}]
	>=sys-fs/btrfs-progs-0.20_rc1_p358"
RDEPEND="${DEPEND}
	dev-python/mako[${PYTHON_USEDEP}]
	dev-python/alembic[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-0.8.2[sqlite,${PYTHON_USEDEP}]"
#	dev-python/contextlib2[${PYTHON_USEDEP}]

#if LIVE
SRC_URI=
KEYWORDS=
#endif

src_unpack() {
	git-r3_src_unpack
	use syscall && git-r3_fetch "https://github.com/markfasheh/duperemove.git" "4b2d8b74618cc7d56c302adb8116b42bc6a3c53a" "duperemove"
}

src_prepare() {
	default

	if use syscall; then
		eapply "${FILESDIR}/${P}-dedup-syscall-master.patch"
		eapply "${FILESDIR}/${P}-time_t.patch"
		rm -f "${S}/duperemove"
		git-r3_checkout "https://github.com/markfasheh/duperemove.git" "${S}/duperemove" "duperemove"
	fi
}
