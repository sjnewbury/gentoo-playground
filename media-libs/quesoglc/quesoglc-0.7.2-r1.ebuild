# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-minimal

DESCRIPTION="Free implementation of the OpenGL Character Renderer (GLC)"
HOMEPAGE="http://quesoglc.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-free.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86"
IUSE="doc"

RDEPEND="
	dev-libs/fribidi[${MULTILIB_USEDEP}]
	media-libs/fontconfig[${MULTILIB_USEDEP}]
	media-libs/freetype:2[${MULTILIB_USEDEP}]
	virtual/glu[${MULTILIB_USEDEP}]
	virtual/opengl[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? (
		app-doc/doxygen
		dev-texlive/texlive-latexextra
		virtual/latex-base
	)"

src_prepare() {
	rm -r src/fribidi || die
	default
	multilib_copy_sources
}

multilib_src_configure() {
	# Uses its own copy of media-libs/glew with GLEW_MX
	local myeconfargs=(
		--disable-executables
		--with-fribidi
		--without-glew
	)
	econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	emake all $(usev doc)
}

multilib_src_install_all() {
	use doc && dodoc -r docs/html
	find "${ED}" -name '*.la' -delete || die
}
