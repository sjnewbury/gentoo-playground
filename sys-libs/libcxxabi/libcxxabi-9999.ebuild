# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

ESVN_REPO_URI="http://llvm.org/svn/llvm-project/libcxxabi/trunk"

[ "${PV%9999}" != "${PV}" ] && SCM="subversion" || SCM=""

inherit ${SCM} eutils cmake-multilib

DESCRIPTION="New implementation of the C++ ABI, targeting C++0X"
HOMEPAGE="http://libcxxabi.llvm.org/"
if [ "${PV%9999}" = "${PV}" ] ; then
        SRC_URI="mirror://gentoo/${P}.tar.xz"
else
        SRC_URI=""
fi

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
if [ "${PV%9999}" = "${PV}" ] ; then
        KEYWORDS="~amd64"
else
        KEYWORDS=""
fi
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
        ~sys-libs/libcxx-${PV}
        sys-libs/libunwind
        >=sys-devel/llvm-3.5
        "

src_prepare() {
	default
	epatch "${FILESDIR}"/${P}-gentoo-llvm-config.patch
}

multilib_src_configure() {
        append-cxxflags -std=c++11

        local abilibdir=$(get_libdir)
        mycmakeargs="
                -DLLVM_LIBDIR_SUFFIX=${abilibdir/lib}
        "
        cmake-utils_src_configure
}

src_install() {
        cmake-multilib_src_install
        rm -fr "${D}"/usr/include
        insinto /usr/include/"${PN}"
        doins -r include/*
        insinto /usr/share/cmake/Modules
        doins "${FILESDIR}"/FindLIBCXXABI.cmake
}
