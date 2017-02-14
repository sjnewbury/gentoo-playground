# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit rpm systemd

FEDORA_T=releases
FEDORA_DR=25
FEDORA_DRV=25
FEDORA_PR=${PV#*_p}
#FEDORA_V="${PV%_*}-${FEDORA_PR}.fc${FEDORA_DR}"
FEDORA_V="${PV%_*}-${FEDORA_PR}.fc${FEDORA_DRV}"
FEDORA_PN="qemu"

DESCRIPTION="Kernel Samepage Merging (KSM) initscripts and ksmtuned daemon from Fedora"
HOMEPAGE="http://fedoraproject.org/wiki/Features/KSM"
SRC_URI="http://download.fedoraproject.org/pub/fedora/linux/${FEDORA_T}/${FEDORA_DR}/Server/source/tree/Packages/q/${FEDORA_PN}-${FEDORA_V}.src.rpm"
#SRC_URI="http://download.fedora.redhat.com/pub/fedora/linux/development/rawhide/source/SRPMS/qemu-${RH_V}.src.rpm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="systemd"
DEPEND="systemd? ( sys-apps/systemd )"


S="${WORKDIR}"
#/"qemu-${P/ksm/kvm}"

src_unpack() {
	rpm_src_unpack
}

src_compile() {
	cd "${S}"
	einfo Gentooizing ...
	#sed -i -e 's:sysconfig:conf.d:g' $(find -name '*.service')
	sed -i \
		-e ':sysconfig:d' \
		ksmtuned.service
	sed -i \
		-e 's/\/usr\/libexec\//\/lib\/systemd\//' \
		ksm.service

	einfo Building ksmctl ...
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} ksmctl.c -o ksmctl || die failed to build ksmctl!
}

src_install() {
	# Install ksm init script and conf.d file
	#newinitd ksm.init ksm
	#newconfd ksm.sysconfig ksm
	systemd_dounit ksm.service || die
	systemd_dounit ksmtuned.service || die
	# Install ksmtuned daemon, config file, and initscript
	dosbin ksmtuned
	insinto /etc
	doins ksmtuned.conf
	exeinto /lib/systemd
	doexe ksmctl
	#newinitd ksmtuned.init ksmtuned
}
