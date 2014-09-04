# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/deluge/deluge-1.3.6.ebuild,v 1.6 2013/09/14 10:05:36 ago Exp $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1 eutils systemd

DESCRIPTION="BitTorrent client with a client/server model."
HOMEPAGE="http://deluge-torrent.org/"
SRC_URI="http://download.deluge-torrent.org/source/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc ~sparc x86"
IUSE="geoip gtk libnotify setproctitle sound webinterface"

DEPEND=">=net-libs/rb_libtorrent-0.14.9[python]
	dev-python/setuptools
	dev-util/intltool"
RDEPEND="${DEPEND}
	dev-python/chardet[${PYTHON_USEDEP}]
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	|| ( dev-lang/python:2.7 dev-lang/python:2.6 dev-python/simplejson[${PYTHON_USEDEP}] )
	>=dev-python/twisted-core-8.1[${PYTHON_USEDEP}]
	>=dev-python/twisted-web-8.1[${PYTHON_USEDEP}]
	>=dev-python/feedparser-5[${PYTHON_USEDEP}]
	geoip? ( dev-libs/geoip )
	gtk? (
		sound? ( dev-python/pygame[${PYTHON_USEDEP}] )
		dev-python/pygame[${PYTHON_USEDEP}]
		dev-python/pygobject:2[${PYTHON_USEDEP}]
		>=dev-python/pygtk-2.12[${PYTHON_USEDEP}]
		gnome-base/librsvg
		libnotify? ( dev-python/notify-python[${PYTHON_USEDEP}] )
	)
	setproctitle? ( dev-python/setproctitle[${PYTHON_USEDEP}] )
	webinterface? ( dev-python/mako[${PYTHON_USEDEP}] )"

python_prepare() {
	distutils-r1_python_prepare
#	python_convert_shebangs -r 2 .
	epatch "${FILESDIR}/${PN}-1.3.5-disable_libtorrent_internal_copy.patch"

}

python_install() {
	distutils-r1_python_install
	newinitd "${FILESDIR}"/deluged.init deluged
	newconfd "${FILESDIR}"/deluged.conf deluged
	systemd_dounit "${FILESDIR}"/deluged.service
	systemd_dounit "${FILESDIR}"/deluge-web.service
}

pkg_postinst() {
	distutils_pkg_postinst
	elog
	elog "If after upgrading it doesn't work, please remove the"
	elog "'~/.config/deluge' directory and try again, but make a backup"
	elog "first!"
	elog
	elog "To start the daemon either run 'deluged' as user"
	elog "or modify /etc/conf.d/deluged and run"
	elog "/etc/init.d/deluged start as root"
	elog "You can still use deluge the old way"
	elog
	elog "For more information look at http://dev.deluge-torrent.org/wiki/Faq"
	elog
}
