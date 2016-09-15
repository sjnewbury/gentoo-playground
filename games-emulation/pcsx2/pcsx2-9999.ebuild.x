# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PLOCALES="ar_SA ca_ES cs_CZ de_DE es_ES fi_FI fr_FR hr_HR hu_HU id_ID it_IT ja_JP ko_KR ms_MY nb_NO pl_PL pt_BR ru_RU sv_SE th_TH tr_TR zh_CN zh_TW"

inherit cmake-utils git-r3 l10n multilib toolchain-funcs wxwidgets

DESCRIPTION="A PlayStation 2 emulator"
HOMEPAGE="http://www.pcsx2.net"
EGIT_REPO_URI=(
	"https://github.com/PCSX2/pcsx2.git"
	"git://github.com/PCSX2/pcsx2.git"
)

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

WX_GTK_VER="3.0-gtk3"

RDEPEND="
	app-arch/bzip2
	app-arch/xz-utils
	dev-libs/libaio
	media-libs/alsa-lib
	media-libs/libpng
	media-libs/libsdl2[joystick,sound]
	media-libs/libsoundtouch
	media-libs/portaudio
	>=sys-libs/zlib-1.2.4
	virtual/jpeg:62
	virtual/opengl
	x11-libs/gtk+:3
	x11-libs/libICE
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/wxGTK:3.0-gtk3[X,-sdl]
"
# Ensure no incompatible headers from eselect-opengl are installed, bug #510730
DEPEND="${RDEPEND}
	>=app-eselect/eselect-opengl-1.3.1
	dev-cpp/pngpp
	>=dev-cpp/sparsehash-1.5
"

clean_locale() {
	rm -R "${S}"/locales/"${1}" || die
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary && $(tc-getCC) == *gcc* ]]; then
		if [[ $(gcc-major-version) -lt 4 || $(gcc-major-version) == 4 && $(gcc-minor-version) -lt 8 ]] ; then
			die "${PN} does not compile with gcc less than 4.8"
		fi
	fi
}

src_prepare() {
	cmake-utils_src_prepare
	l10n_for_each_disabled_locale_do clean_locale
}

src_configure() {
	multilib_toolchain_setup x86

	# pcsx2 build scripts will force CMAKE_BUILD_TYPE=Devel
	# if it something other than "Devel|Debug|Release"
	local CMAKE_BUILD_TYPE="Release"

	local mycmakeargs=(
		-DARCH_FLAG=
		-DDISABLE_BUILD_DATE=TRUE
		-DDISABLE_PCSX2_WRAPPER=TRUE
		-DEXTRA_PLUGINS=FALSE
		-DOPTIMIZATION_FLAG=
		-DPACKAGE_MODE=TRUE
		-DXDG_STD=TRUE

		-DCMAKE_INSTALL_PREFIX=/usr
		-DCMAKE_LIBRARY_PATH="/usr/$(get_libdir)/${PN}"
		-DDOC_DIR=/usr/share/doc/"${PF}"
		-DEGL_API=FALSE
		-DGTK3_API=TRUE
		-DPLUGIN_DIR="/usr/$(get_libdir)/${PN}"
		# wxGTK must be built against same sdl version
		-DSDL2_API=TRUE
		-DWX28_API=FALSE
	)

	cmake-utils_src_configure
}

src_install() {
	# Upstream issue: https://github.com/PCSX2/pcsx2/issues/417
	QA_TEXTRELS="usr/$(get_libdir)/pcsx2/*"

	cmake-utils_src_install
}
