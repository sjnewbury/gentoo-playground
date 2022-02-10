# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9,10} )

inherit python-single-r1 scons-utils toolchain-funcs xdg-utils

if [[ ${PV} == 9999* ]]; then
        SRC_URI=
        EGIT_REPO_URI="https://github.com/sahib/${PN}.git"
        inherit git-r3
else
        SRC_URI="https://github.com/sahib/${PN}/archive/refs/tags/v${PV}.tar.gz
        -> ${P}.tar.gz"
        KEYWORDS="~amd64 ~x86"
fi


DESCRIPTION="finds space waste and other broken things on your filesystem and offers to remove it."
HOMEPAGE="https://github.com/sahib/${PN}"

LICENSE="GPL-3+"
SLOT="0"

IUSE="doc"

RDEPEND="
        ${PYTHON_DEPS}
"

DEPEND="${RDEPEND}
        >=dev-libs/glib-2.32
        sys-apps/util-linux
        dev-libs/elfutils
        dev-libs/json-glib
        sys-devel/gettext
        $(python_gen_cond_dep '
                doc? ( dev-python/sphinx[${PYTHON_MULTI_USEDEP}] )
                ')
"

src_configure() {
        MYSCONS=(
                CC="$(tc-getCC)"
                SYMBOLS=1 DEBUG=1 VERBOSE=1
                --actual-prefix="${EROOT}/usr"
                --prefix="${D}"/usr
                --libdir=lib64
        )

        if ! use doc; then
                sed -i -e "/sphinx_bin =/s/\(find_sphinx_binary()\)/\'\' #\1/" \
                        ${S}/SConstruct ${S}/docs/SConscript || die sed failed
        fi

        escons config "${MYSCONS[@]}"
}

src_compile() {
        escons "${MYSCONS[@]}"
}

src_install() {
        escons install "${MYSCONS[@]}"
        python_optimize

	# Should not be installed
	rm -f "${D}"/usr/share/glib-2.0/schemas/gschemas.compiled || die

	# rather than more hacking of the build system ...
	use doc && gunzip "${D}"/usr/share/man/man1/rmlint.1.gz
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
