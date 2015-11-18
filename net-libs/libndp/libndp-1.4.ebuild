# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=5

inherit multilib-minimal

DESCRIPTION="A library which provides a wrapper for IPv6 Neighbor Discovery Protocol"
HOMEPAGE=http://libndp.org/

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

SRC_URI="http://libndp.org/files/${P}.tar.gz"

ECONF_SOURCE="${S}"

