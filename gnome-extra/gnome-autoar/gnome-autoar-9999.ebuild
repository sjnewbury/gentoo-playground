# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="Automatic archive creation and extraction for GNOME"
HOMEPAGE="https://wiki.gnome.org/Design/OS/Archives"

LICENSE="GPL-2+"
SLOT="0"
IUSE=""
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
fi
RDEPEND="
	>=dev-libs/gobject-introspection-0.9.6
	>=dev-libs/glib-2.35.6:2
	>=x11-libs/gtk+-3.12:3
	>=app-arch/libarchive-3.1.0
"
DEPEND="${RDEPEND}
	dev-libs/libxslt
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"
