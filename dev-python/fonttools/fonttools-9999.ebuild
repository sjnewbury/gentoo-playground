# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9,10,11,12} )
PYTHON_REQ_USE="xml(+)"

inherit distutils-r1
if [[ -z ${PV%%*9999} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"
else
	[[ -z ${PV%%*_p*} ]] && MY_PV="66d847e"
	MY_PV="${PV}"
	SRC_URI="
		mirror://githubcl/${PN}/${PN}/tar.gz/${MY_PV} -> ${P}.tar.gz
	"
	RESTRICT="primaryuri"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${PN}-${MY_PV}"
fi

DESCRIPTION="Library for manipulating TrueType, OpenType, AFM and Type1 fonts"
HOMEPAGE="https://github.com/${PN}/${PN}"

LICENSE="BSD"
SLOT="0"
IUSE="doc graphite gtk interpolatable plot png qt5 reportlab symfont +ufo +unicode woff"
DOCS=( {README,NEWS}.rst )
PATCHES=(
	"${FILESDIR}"/${PN}-xattr.diff
)

# README.rst: Optional Requirements
RDEPEND="
	>=dev-python/lxml-4.5[${PYTHON_USEDEP}]
	>=app-arch/brotli-1.0.9[python,${PYTHON_USEDEP}]
	woff? (
		dev-python/py-zopfli[${PYTHON_USEDEP}]
	)
	ufo? (
		>=dev-python/fs-2.4.11[${PYTHON_USEDEP}]
	)
	unicode? (
		>=dev-python/unicodedata2-13[${PYTHON_USEDEP}]
	)
	qt5? ( dev-python/PyQt5[${PYTHON_USEDEP}] )
	gtk? ( dev-python/pygobject:3[${PYTHON_USEDEP}] )
	graphite? ( dev-python/lz4[${PYTHON_USEDEP}] )
	plot? ( dev-python/matplotlib[${PYTHON_USEDEP}] )
	symfont? ( dev-python/sympy[${PYTHON_USEDEP}] )
	interpolatable? ( >=dev-python/scipy-1.5.2[${PYTHON_USEDEP}] )
	reportlab? ( dev-python/reportlab[${PYTHON_USEDEP}] )
	dev-python/ufoLib2[${PYTHON_USEDEP}]
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
"
distutils_enable_sphinx Doc/source dev-python/sphinx_rtd_theme
distutils_enable_tests pytest
