# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

DESCRIPTION="A cross-platform library for USB video devices, built atop libusb"
HOMEPAGE="https://int80k.com/libuvc/"

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI=https://github.com/libuvc/libuvc.git
	inherit git-r3
else
	SRC_URI="https://github.com/ktossell/libuvc/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~x86"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND="
	virtual/jpeg:0
	virtual/libusb:1
	virtual/udev
"
DEPEND="${RDEPEND}"

CMAKE_MIN_VERSION="2.8.0"

DOCS=( changelog.txt README.md )

src_prepare() {
	sed -r -i \
		-e 's/(\$\{CMAKE_INSTALL_PREFIX\}\/)lib/\1'"$(get_libdir)"'/' \
		-e 's/LANGUAGES C/LANGUAGES C CXX/' \
		CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TARGET=Shared
	)

	cmake-utils_src_configure
}
