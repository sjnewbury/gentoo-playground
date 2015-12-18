# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

WX_GTK_VER="3.0"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="threads,ssl"

EGIT_REPO_URI=https://github.com/0ad/0ad.git
if [[ ${PV} == 9999* ]]; then
	GIT_ECLASS="git-r3"
fi

inherit eutils wxwidgets toolchain-funcs gnome2-utils python-any-r1 games flag-o-matic ${GIT_ECLASS}

MY_P=0ad-${PV/_/-}
DESCRIPTION="A free, real-time strategy game"
HOMEPAGE="http://play0ad.com/"

if [[ ${PV} == 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="mirror://sourceforge/zero-ad/${MY_P}-unix-build.tar.xz"
fi

LICENSE="GPL-2 LGPL-2.1 MIT CC-BY-SA-3.0 ZLIB"
SLOT="0"
KEYWORDS=""
IUSE="editor +lobby nvtt pch sound test"
RESTRICT="test"

RDEPEND="
	dev-libs/boost
	dev-libs/icu:=
	dev-libs/libxml2
	dev-libs/nspr
	media-libs/libpng:0
	media-libs/libsdl2[X,opengl,video]
	net-libs/enet:1.3
	net-libs/miniupnpc:=
	net-misc/curl
	sys-libs/zlib
	virtual/jpeg:0
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXcursor
	editor? ( x11-libs/wxGTK:${WX_GTK_VER}[X,opengl] )
	lobby? ( net-libs/gloox )
	nvtt? ( media-gfx/nvidia-texture-tools )
	sound? ( media-libs/libvorbis
		media-libs/openal )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig
	test? ( dev-lang/perl )"

PDEPEND="~games-strategy/0ad-data-${PV}"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	games_pkg_setup
	python-any-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.0.19_alpha-gentoo.patch
#	epatch "${FILESDIR}"/${PN}-0.0.19_alpha-miniupnpc14.patch
	epatch "${FILESDIR}"/${PN}-0.0.19_alpha-spidermonkey-cxxflags.patch
	#epatch "${FILESDIR}"/${P}-GL4.patch

	# Make COLLADA plugins happy
	strip-flags
}

src_configure() {
	local myconf=(
		--with-system-nvtt
		--with-system-miniupnpc
		--minimal-flags
		--sdl
		$(usex nvtt "" "--without-nvtt")
		$(usex pch "" "--without-pch")
		$(usex test "" "--without-tests")
		$(usex sound "" "--without-audio")
		$(usex editor "--atlas" "")
		$(usex lobby "" "--without-lobby")
		--collada
		--bindir="${GAMES_BINDIR}"
		--libdir="/usr/$(get_libdir)"/${PN}
		--datadir="${GAMES_DATADIR}"/${PN}
		)

	# stock premake4 does not work, use the shipped one
	emake -C "${S}"/build/premake/premake4/build/gmake.unix

	# regenerate scripts.c so our patch applies
	cd "${S}"/build/premake/premake4 || die
	"${S}"/build/premake/premake4/bin/release/premake4 embed || die

	# rebuild premake again... this is the most stupid build system
	emake -C "${S}"/build/premake/premake4/build/gmake.unix clean
	emake -C "${S}"/build/premake/premake4/build/gmake.unix

	# run premake to create build scripts
	cd "${S}"/build/premake || die
	"${S}"/build/premake/premake4/bin/release/premake4 \
		--file="premake4.lua" \
		--outpath="../workspaces/gcc/" \
		--platform=$(usex amd64 "x64" "x32") \
		--os=linux \
		"${myconf[@]}" \
		gmake || die "Premake failed"
}

src_compile() {
	tc-export AR

	# build bundled and patched spidermonkey
	cd libraries/source/spidermonkey || die
	JOBS="${MAKEOPTS}" ./build.sh || die
	cd "${S}" || die

	# build 3rd party fcollada
	emake -C libraries/source/fcollada/src

	# build 0ad
	emake -C build/workspaces/gcc verbose=1
}

src_test() {
	cd binaries/system || die
	./test -libdir "${S}/binaries/system" || die "test phase failed"
}

src_install() {
	# Needs to be available for building 0ad-data
	dobin binaries/system/pyrogenesis 
	dosym /usr/bin/pyrogenesis "${GAMES_BINDIR}"/0ad
	use editor && newgamesbin binaries/system/ActorEditor 0ad-ActorEditor

	insinto "${GAMES_DATADIR}"/${PN}
	doins -r binaries/data/l10n

	# Need to be available for building 0ad-data
	insinto "/usr/$(get_libdir)"/${PN}
	doins binaries/system/libCollada.so
	doins libraries/source/spidermonkey/lib/*.so
	use editor && doins binaries/system/libAtlasUI.so

	dodoc binaries/system/readme.txt
	doicon -s 128 build/resources/${PN}.png
	make_desktop_entry ${PN}

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
