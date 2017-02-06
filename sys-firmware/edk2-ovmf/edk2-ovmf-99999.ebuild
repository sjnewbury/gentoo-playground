# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils multiprocessing toolchain-funcs python-r1 flag-o-matic

DESCRIPTION="EDK II Open Source UEFI Firmware"
HOMEPAGE="http://tianocore.sourceforge.net"

LICENSE="BSD-2"
SLOT="0"
IUSE="debug +qemu +secure-boot custom-cflags"

if [[ ${PV} == 99999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/tianocore/edk2"
	KEYWORDS=""
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/tianocore/edk2"
	EGIT_BRANCH=UDK${PV}
	KEYWORDS="-* amd64"
fi

OPENSSL_PV="1.0.2j"
OPENSSL_P="openssl-${OPENSSL_PV}"
SRC_URI+=" mirror://openssl/source/${OPENSSL_P}.tar.gz"

DEPEND=">=dev-lang/nasm-2.0.7
	sys-power/iasl
	${PYTHON_DEPS}"
RDEPEND="qemu? ( app-emulation/qemu )"

src_unpack() {
	git-r3_src_unpack
	default
}

src_prepare() {
	use custom-cflags || strip-flags

	epatch "${FILESDIR}"/edk2-dereference-StringPtr.patch

	# This build system is impressively complicated, needless to say
	# it does things that get confused by PIE being enabled by default.
	# Add -nopie to a few strategic places... :)
	if gcc-specs-pie; then
		epatch "${FILESDIR}/edk2-nopie.patch"
	fi

	sed -i \
		-e '/BUILD_CFLAGS/s/\(BUILD_CFLAGS\) = \(.*\)$/\1 = $(CFLAGS) \2/g' \
		-e '/BUILD_CXXFLAGS/s/\(BUILD_CXXFLAGS\) = \(.*\)$/\1 = $(CXXFLAGS) \2/g' \
		-e '/BUILD_CPPFLAGS/s/\(BUILD_CPPFLAGS\) = \(.*\)$/\1 = $(CPPFLAGS) \2/g' \
		-e '/BUILD_LFLAGS/s/\(BUILD_LFLAGS\) = \(.*\)$/\1 = $(LDFLAGS) \2/g' \
		BaseTools/Source/C/Makefiles/*.makefile

	if use secure-boot; then
		local openssllib="${S}/CryptoPkg/Library/OpensslLib"
		mv "${WORKDIR}/${OPENSSL_P}" "${openssllib}" || die
		cd "${openssllib}/${OPENSSL_P}"
		epatch "${openssllib}/EDKII_${OPENSSL_P}.patch"
		cd "${openssllib}"
		sh -e ./Install.sh || die
		cd "${S}"
	fi

	epatch_user
}

src_configure() {

	TARGET_NAME=$(usex debug DEBUG RELEASE)
	TARGET_TOOLS="GCC$(gcc-version | tr -d .)"
	case ${TARGET_TOOLS} in
		GCC[6-7]*) TARGET_TOOLS=GCC5 ;;
	esac
	case $ARCH in
		amd64)	TARGET_ARCH=X64 ;;
		#x86)	TARGET_ARCH=IA32 ;;
		*)		die "Unsupported $ARCH" ;;
	esac

	. edksetup.sh || die
}

src_compile() {
	python_export_best

	emake ARCH=${TARGET_ARCH} -C BaseTools -j1

	./OvmfPkg/build.sh \
		-a "${TARGET_ARCH}" \
		-b "${TARGET_NAME}" \
		-t "${TARGET_TOOLS}" \
		-n $(makeopts_jobs) \
		-D SECURE_BOOT_ENABLE=$(usex secure-boot TRUE FALSE) \
		-D FD_SIZE_2MB \
		|| die "OvmfPkg/build.sh failed"
}

src_install() {
	local fv="Build/OvmfX64/${TARGET_NAME}_${TARGET_TOOLS}/FV"
	insinto /usr/share/${PN}
	doins "${fv}"/OVMF{,_CODE,_VARS}.fd
	dosym OVMF.fd /usr/share/${PN}/bios.bin

	if use qemu; then
		dosym ../${PN}/OVMF.fd /usr/share/qemu/efi-bios.bin
	fi
}
