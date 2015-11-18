# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Steven Newbury.  https://bugs.gentoo.org/show_bug.cgi?id=396681

EAPI=4

WANT_ANT_TASKS="ant-nodeps"

inherit eutils user java-pkg-2 java-ant-2 multilib flag-o-matic systemd

JETTY_V="6.1.26"
WRAPPER_V="3.5.22"

DESCRIPTION="I2P is an anonymous network, exposing a simple layer that applications can use to anonymously and securely send messages to each other."
SRC_URI="https://download.i2p2.de/releases/${PV}/i2psource_${PV}.tar.bz2
	http://dist.codehaus.org/jetty/jetty-${JETTY_V}/jetty-${JETTY_V}-src.zip
	http://wrapper.tanukisoftware.com/download/${WRAPPER_V}/wrapper_${WRAPPER_V}_src.tar.gz"
#http://mirror.i2p2.de/i2psource_${PV}.tar.bz2

HOMEPAGE="http://www.i2p.net/"

SLOT="0"
KEYWORDS="~x86 ~amd64"
LICENSE="GPL-2"
IUSE=""
DEPEND=">=virtual/jdk-1.6
	dev-java/ant"


#QA_TEXTRELS="usr/$(get_libdir)/${P}/i2psvc"
#QA_EXECSTACK="usr/$(get_libdir)/${P}/i2psvc"

I2P_BASE_DIR=/var/"${PN}"
I2P_CONF_DIR=/etc/"${PN}"
I2P_LOG_DIR=/var/log/"${PN}"
I2P_TMP_DIR=/var/tmp/"${PN}"
I2P_PID_DIR=/run/"${PN}"

WRAPPER_S="${WORKDIR}/wrapper_${WRAPPER_V}_src"

src_unpack() {
	unpack i2psource_${PV}.tar.bz2
	unpack wrapper_${WRAPPER_V}_src.tar.gz
	cp ${DISTDIR}/jetty-${JETTY_V}-src.zip -P ${S}/apps/jetty || die
}

src_prepare() {

	# Use our CFLAGS/LDFLAGS
	for makefile in "${WRAPPER_S}"/src/c/Makefile-linux-*.make; do
		sed -i \
			-e 's/gcc -O3/\$(CC) \$(CFLAGS)/g' \
			-e 's/\(\$.COMPILE.\)\(.*-o\)/\1 \$(LDFLAGS) \2/g' \
			"${makefile}" || die sed failed
	done
}

src_compile() {
	strip-flags

	# build java service wrapper
	pushd "${WRAPPER_S}"
		libdir=$(get_libdir)
		if [ "${libdir/lib}" = "64" ]; then 
			eant -Dbits=64 || die
		else
			eant -Dbits=32 || die
		fi	
	popd

	# build i2p
	eant pkg || die
}

src_install() {
	dodir /usr/$(get_libdir)/${P} /usr/bin
	exeinto /usr/$(get_libdir)/${P}
	# Remove distributed binary java wrapper
	rm -rf "${S}"/pkg-temp/lib/wrapper*
	cp -r "${S}"/pkg-temp/* "${D}"/usr/$(get_libdir)/${P}/
	doexe pkg-temp/i2prouter pkg-temp/osid pkg-temp/postinstall.sh pkg-temp/eepget pkg-temp/*.config

	# install java service wrapper
	newexe "${WRAPPER_S}"/bin/wrapper i2psvc
	cp "${WRAPPER_S}"/lib/libwrapper.so "${D}"/usr/$(get_libdir)/${P}/lib/
	cp "${WRAPPER_S}"/lib/wrapper.jar "${D}"/usr/$(get_libdir)/${P}/lib/

	rm -rf "${D}"/usr/"$(get_libdir)"/"${P}"/icons
	rm -f "${D}"/usr/"$(get_libdir)"/"${P}"/lib/*.dll "${D}"/usr/"$(get_libdir)"/"${P}"/*.bat
	dosym "${D}"/usr/"$(get_libdir)"/"${P}"/i2prouter /usr/bin/i2prouter

	diropts "-m0755"
	for directory in \
				"${I2P_CONF_DIR}" \
				"${I2P_TMP_DIR}" \
				"${I2P_LOG_DIR}" \
				"${I2P_BASE_DIR}"; do
		mkdir -p "${D}"/"${directory}"
		dodir "${directory}"
		keepdir "${directory}"
		chown i2p:i2p "${D}"/"${directory}"
	done

	sed -i \
		-e "s:%INSTALL_PATH:/usr/$(get_libdir)/${P}:" \
		-e "s:%SYSTEM_java_io_tmpdir:/var/tmp/${P}:" \
		-e "s:^\(WRAPPER_CONF\)=.*:\1=/etc/i2p/wrapper.config:" \
		-e "s:^\(PIDDIR\)=.*:\1=${I2P_PID_DIR}:" \
		"${D}"/usr/"$(get_libdir)"/"${P}"/i2prouter || die Failed to update i2prouter script

	insopts -o i2p -g i2p -m 0644
	dosym "${D}"/usr/"$(get_libdir)"/"${P}"/webapps "${I2P_BASE_DIR}"/webapps

	# Fix country flags
	dodir "${I2P_BASE_DIR}"/geoip
	insinto "${I2P_BASE_DIR}"/geoip
	doins "${D}"/usr/"$(get_libdir)"/"${P}"/geoip/countries.txt
	doins "${D}"/usr/"$(get_libdir)"/"${P}"/geoip/geoip.txt

	#dosym "${D}"/usr/"$(get_libdir)"/"${P}"/docs "${I2P_BASE_DIR}"/docs
	dosym "${D}"/usr/"$(get_libdir)"/"${P}"/lib "${I2P_BASE_DIR}"/lib
	insinto "${I2P_BASE_DIR}"
	doins "${D}"/usr/"$(get_libdir)"/"${P}"/hosts.txt
	doins "${D}"/usr/"$(get_libdir)"/"${P}"/blocklist.txt
	dosym "${I2P_BASE_DIR}"/hosts.txt "${I2P_CONF_DIR}"/hosts.txt
	dosym "${I2P_BASE_DIR}"/blocklist.txt "${I2P_CONF_DIR}"/blocklist.txt

	dodir "${I2P_BASE_DIR}"/eepsite
	keepdir "${I2P_BASE_DIR}"/eepsite
	cp -r \
		"${D}"/usr/"$(get_libdir)"/"${P}"/eepsite "${D}"/"${I2P_BASE_DIR}" \
		|| die Failed to copy eepsite

	dodir "${I2P_BASE_DIR}"/eepsite
	chown -R i2p:i2p "${D}"/"${I2P_BASE_DIR}"/eepsite

	# Remove installed jetty.xml and replace with our version
	rm -f ${D}/"${I2P_BASE_DIR}"/eepsite/jetty.xml
	# Set absolute paths in jetty.xml, change log location
	sed	-e "s:\.\/eepsite:${I2P_BASE_DIR}/eepsite:g" \
		-e "s:\.\/webapps:${I2P_BASE_DIR}/webapps:g" \
		-e "s:/var/i2p/eepsite/logs:"${I2P_LOG_DIR}"/eepsite:g" \
		"${D}"/usr/"$(get_libdir)"/"${P}"/eepsite/jetty.xml \
		> "${D}"/"${I2P_CONF_DIR}"/jetty.xml || die Failed to set absolute paths in jetty.xml

	chown i2p:i2p "${D}"/"${I2P_CONF_DIR}"/jetty.xml
	dosym "${I2P_CONF_DIR}"/jetty.xml "${I2P_BASE_DIR}"/eepsite/jetty.xml

	# symlink eepsite into config directory for addressbook etc
	dosym "${I2P_BASE_DIR}"/eepsite "${I2P_CONF_DIR}"/eepsite

	# eepsite log
	dodir "${I2P_LOG_DIR}"/eepsite
	keepdir "${I2P_LOG_DIR}"/eepsite
	chown -R i2p:i2p "${D}"/"${I2P_LOG_DIR}"/eepsite

	# For i2p news etc
	dodir "${I2P_BASE_DIR}"/docs
	cp -r "${D}"/usr/"$(get_libdir)"/"${P}"/docs ${D}/"${I2P_BASE_DIR}"
	dosym "${I2P_BASE_DIR}"/docs "${I2P_CONF_DIR}"/docs
	chown -R i2p:i2p "${D}"/"${I2P_BASE_DIR}"/docs

	# Generate /etc/i2p/wrapper.config
	echo	"# Autogenerated from /usr/$(get_libdir)/${P}/wrapper.config" \
		> "${T}/wrapper.config"
	sed	-e '/^#/d' \
		-e '/^$/d' \
		-e 's:^wrapper\.java\.command.*:wrapper\.java\.command=/etc/java-config-2/current-system-vm/bin/java:g' \
		-e "s:\$INSTALL_PATH:/usr/$(get_libdir)/${P}:g" \
		-e "s:\$SYSTEM_java_io_tmpdir:/var/tmp/${P}:g" \
		-e "s:=.*\/\(.*\)\.pid$:=${I2P_PID_DIR}/\1\.pid:g" \
		-e "s:=.*\/\(.*\)\.log$:=${I2P_LOG_DIR}/\1\.log:g" \
		-e "s:Override=logs:Override=${I2P_LOG_DIR}:" \
		-e "s:\(i2p.dir.base\)=.*$:\1=\"${I2P_BASE_DIR}\":" \
		"${D}"/usr/"$(get_libdir)"/"${P}"/wrapper.config \
		>> "${T}"/wrapper.config || die Failed to update wrapper.config
		cat >>"${T}"/wrapper.config <<EOF
wrapper.java.additional.5=-Djava.net.preferIPv4Stack=false
wrapper.java.additional.6=-Djava.net.preferIPv6Addresses=true
wrapper.java.additional.7=-Di2p.dir.pid="${I2P_PID_DIR}"
wrapper.java.additional.7.stripquotes=TRUE
wrapper.java.additional.8=-Di2p.dir.temp="${I2P_TMP_DIR}"
wrapper.java.additional.8.stripquotes=TRUE
wrapper.java.additional.9=-Di2p.dir.config="${I2P_CONF_DIR}"
wrapper.java.additional.9.stripquotes=TRUE
wrapper.java.additional.10=-Drouter.configLocation="${I2P_CONF_DIR}/router.config"
wrapper.java.additional.10.stripquotes=TRUE
EOF

	insinto "${I2P_CONF_DIR}"
	doins "${T}"/wrapper.config
	for configfile in \
		"clients.config" \
		"systray.config" \
		"i2psnark.config" \
		"i2ptunnel.config"; do
		doins "${D}"/usr/"$(get_libdir)"/"${P}"/"${configfile}"
	done

	# Disable autolaunched web browser on server startup, change eepsite location
	sed -i	-e "s:\(clientApp\.4\.startOnLoad\)=.*:\1=false:" \
		-e "s:\(clientApp\.3\.args\)=.*:\1=\"/var/i2p/eepsite/jetty.xml\":" \
		"${D}"/"${I2P_CONF_DIR}"/clients.config || die failed to disable browser

	# Change default i2psnark data dir
	sed -i -e "s:\(i2psnark\.dir\)=.*:\1=${I2P_BASE_DIR}/i2psnark:" \
		"${D}"/"${I2P_CONF_DIR}"/i2psnark.config || die failed to disable browser

	local infilepath
	for infilepath in ${FILESDIR}/*.in; do
		local infile=${infilepath/${FILESDIR}\/}
		sed -e "s:%I2PDIR%:/usr/$(get_libdir)/${P}:g" \
			-e "s:%I2PPIDDIR%:${I2P_PID_DIR}:g" \
			-e "s:%I2PCONFDIR%:${I2P_CONF_DIR}:g" \
			"${infilepath}" > "${T}"/"${infile%.in}" || die Failed to proccess infiles
	done

	exeinto /etc/init.d
	newexe "${T}"/i2p.initd i2p

	systemd_dounit "${T}"/i2p.service
	systemd_dotmpfilesd "${T}"/i2p.conf

	doman "${D}"/usr/"$(get_libdir)"/"${P}"/man/*.1
}

pkg_preinst() {
	enewgroup i2p
	enewuser i2p -1 -1 /var/${PN} i2p -m
}

pkg_postinst() {
	einfo "Configure the router now : http://localhost:7657/index.jsp"
	einfo "Use /etc/init.d/i2p start to start I2P"
}
