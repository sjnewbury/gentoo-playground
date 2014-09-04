# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/perl-ldap/perl-ldap-0.430.0.ebuild,v 1.1 2011/11/06 08:30:15 tove Exp $

EAPI=5

MODULE_AUTHOR=REVMISCHA
MODULE_VERSION=9999
inherit perl-module git-r3

SRC_URI=
EGIT_REPO_URI="https://github.com/revmischa/rtsp-server.git"

DESCRIPTION="Lightweight RTSP/RTP streaming media server"

SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="dev-perl/AnyEvent
		 dev-perl/Moose
		 dev-perl/namespace-autoclean
		 dev-perl/MooseX-Getopt
"
DEPEND="${RDEPEND}"

#SRC_TEST=do
