# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="Free and Open Source API and drivers for immersive technology"
HOMEPAGE="https://www.openhmd.net"

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI=https://github.com/${PN}/${PN}
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi
LICENSE="Boost-1.0"
SLOT="0"
IUSE="+hidraw opengl test"

REQUIRED_USE=""

IUSE_HMD_DEVICES=(
	rift deepon psvr vive nolo wmr xgvr vrtek external android
)

# Add supported drivers from 'IUSE_HMD_DEVICES' to 'IUSE' and 'REQUIRED_USE'
REQUIRED_USE+=" || ( "
for HMD_DEVICE in "${IUSE_HMD_DEVICES[@]}"; do
	HMD_DEVICE=${HMD_DEVICE,,}
	IUSE+=" hmd_devices_${HMD_DEVICE} "
	REQUIRED_USE+=" hmd_devices_${HMD_DEVICE} "
done
REQUIRED_USE+=" ) "
unset HMD_DEVICE

DEPEND="	dev-libs/hidapi
		!hidraw? ( virtual/libusb )
		opengl? ( virtual/opengl )
"

src_configure() {
	# Enable all users enabled HMD devices
	local emesonargs_hmd_devices
	for hmd_device in "${IUSE_HMD_DEVICES[@]}"; do
		if use "hmd_devices_${hmd_device,,}"; then
			emesonargs_hmd_devices+=",${hmd_device}"
		fi
	done

	local emesonargs=(
		-Ddrivers="${emesonargs_hmd_devices#,}"
		-Dexamples="$(usex opengl opengl simple)"
		-Dhidapi="$(usex hidraw hidraw libusb)"
		$(meson_use test tests)
	)

	meson_src_configure
}
