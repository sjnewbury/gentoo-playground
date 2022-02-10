# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit eutils toolchain-funcs

DESCRIPTION="Freeze/unfreeze compression program"
HOMEPAGE="http://www.ibiblio.org/pub/Linux/utils/compress/"
SRC_URI="ftp://ftp.ibiblio.org/pub/Linux/utils/compress/${P}.tar.gz"

LICENSE="GPL-1+"
SLOT="0"
KEYWORDS="alpha amd64 hppa ppc ppc64 sparc x86"
IUSE="melt"

RDEPEND="
	melt? (
		!<=media-libs/mlt-0.4.2
		!media-libs/mlt[melt]
	)
"
PATCHES=(
	"${FILESDIR}"/${P}-gentoo.patch
	"${FILESDIR}"/${P}-pipe-not-comma.patch
	"${FILESDIR}"/${P}-fixes.patch
)

src_compile() {
	emake \
		CC=$(tc-getCC) \
		OPTIONS="-DDEFFILE=\\\"/etc/freeze.cnf\\\""
}

src_install() {
	dodir /usr/bin /usr/share/man/man1

	emake \
		DEST="${D}/usr/bin" \
		MANDEST="${D}/usr/share/man/man1" \
		install

	# these symlinks collide with app-forensics/sleuthkit (bug #444872)
	rm "${D}"/usr/bin/fcat "${D}"/usr/share/man/man1/fcat.1 || die

	# Conflicts with "melt" binary from media-libs/mlt
	use melt || rm "${D}"/usr/bin/melt "${D}"/usr/share/man/man1/melt.1

	dobin showhuf
	dodoc README *.lsm
}
