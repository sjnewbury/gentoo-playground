# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 git-r3

DESCRIPTION="ltConfig is a plugin for Deluge that allows direct modification to libtorrent settings and has preset support."
HOMEPAGE="https://github.com/ratanakvlun/deluge-ltconfig"
#SRC_URI=
EGIT_REPO_URI=https://github.com/ratanakvlun/deluge-ltconfig.git

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="net-p2p/deluge
	dev-python/setuptools[${PYTHON_USEDEP}]"

#PATCHES=(
#)

python_prepare_all() {
	distutils-r1_python_prepare_all
}

python_compile_all() {
	"${PYTHON}" setup.py bdist_egg
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /usr/lib64/python2.7/site-packages/deluge/plugins
	doins dist/*
}
