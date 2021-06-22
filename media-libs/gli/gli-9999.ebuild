# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="OpenGL Image (GLI) is a header only C++ image library for graphics software."
HOMEPAGE="http://gli.g-truc.net/"

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI=https://github.com/g-truc/gli.git
	inherit git-r3
else
	SRC_URI="https://github.com/g-truc/gli/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~sparc ~x86"
fi

LICENSE="|| ( HappyBunny MIT )"
SLOT="0"
IUSE="test cpu_flags_x86_sse2 cpu_flags_x86_sse3 cpu_flags_x86_avx cpu_flags_x86_avx2"
RESTRICT="!test? ( test )"

src_configure() {
	# Header-only library
	if use test; then
		local mycmakeargs=(
			-DGLI_TEST_ENABLE=ON
		)
	fi
	cmake_src_configure

	GLI_V=$(grep set\(GLI_VERSION CMakeLists.txt | grep -oP '"\K[^"\047]+(?=["\047])')

	sed \
		-e "s:@CMAKE_INSTALL_PREFIX@:${EPREFIX}/usr:" \
		-e "s:@GLI_VERSION@:$(ver_cut 1-3 ${GLI_V}):" \
		"${FILESDIR}"/gli.pc.in \
		> "${BUILD_DIR}/gli.pc" || die

}

src_install() {
	cmake_src_install
	insinto /usr/share/pkgconfig
	doins "${BUILD_DIR}/gli.pc"
	dodoc readme.md manual.md
}
