# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

PYTHON_COMPAT=( python3_{9,10,11,12} )

inherit python-single-r1 python-utils-r1

if [[ ${PV} == 9999* ]]; then
	SRC_URI=
	EGIT_REPO_URI="https://github.com/Lakshmipathi/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/Lakshmipathi/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi


DESCRIPTION="Btrfs file de-duplication tool"
HOMEPAGE="https://github.com/Lakshmipathi/${PN}"

LICENSE="GPL-2+"
SLOT="0"

# we need btrfs-progs with csum patch.
RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/prettytable[${PYTHON_SINGLE_USEDEP}]
		dev-python/numpy[${PYTHON_SINGLE_USEDEP}]
		'
	)
"
DEPEND="${RDEPEND}
	sys-fs/btrfs-progs[dump-csum]"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_install() {
	python_doexe ${PN}
}
