# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A small and simple LightDM greeter using Python and GTK that doesn't require an X11 server."
HOMEPAGE="https://github.com/max-moser/lightdm-elephant-greeter"
SRC_URI="https://github.com/max-moser/lightdm-elephant-greeter/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="virtual/pkgconfig"

RDEPEND="
	>=x11-libs/gtk+-3.14:3
	>=x11-misc/lightdm-1.12
"
DEPEND="${RDEPEND}"

DOCS="CHANGELOG.md README.md"

src_install() {
	emake INSTALL_PATH=/usr PKG_PREFIX="${D}" install
}
