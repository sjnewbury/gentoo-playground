# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9,10,11,12} )

inherit autotools flag-o-matic python-single-r1 systemd

DESCRIPTION="A small program that grabs information and displays it on an external LCD"
HOMEPAGE="https://lcd4linux.bulix.org/"

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI=https://github.com/feckert/lcd4linux
	EGIT_BRANCH=pr/feature
else
	SRC_URI="https://www.bl4ckb0x.de/files/${P}.tar.bz2"
	KEYWORDS="~amd64 ~x86"
fi
LICENSE="GPL-2"
SLOT="0"
IUSE="dmalloc outb"
REQUIRED_USE="
	?? ( lcd_devices_hd44780 lcd_devices_hd44780-i2c )
	python? ( ${PYTHON_REQUIRED_USE} )
"

PATCHES=(
	"${FILESDIR}/list-to-help.patch"
	"${FILESDIR}/${PN}-0.11.0_pre20170527-python3.patch"
)

# Define the list of valid lcd devices.
# Some drivers were removed from this list:
# - lcdlinux: It's an ancient driver, which needs app-misc/lcd-linux, that made it never to the portage tree.
# - lcdlinux: Besides, app-misc/lcd-linux won't compile on a modern linux kernel.
# - st2205: It's needs dev-libs/libst2205, which made it never to the portage tree and is quite outdated.
IUSE_LCD_DEVICES=(
	ASTUSB BeckmannEgle BWCT CrystalFontz Curses Cwlinux D4D DPF EA232graphic EFN FutabaVFD
	FW8888 G15 GLCD2USB HD44780 HD44780-I2C IRLCD LCD2USB LCDTerm LEDMatrix LPH7508 LUIse LW_ABP M50530
	MatrixOrbital MatrixOrbitalGX MilfordInstruments MDM166A Newhaven Noritake NULL Pertelian PHAnderson
	PICGraphic picoLCD picoLCDGraphic PNG PPM RouterBoard Sample SamsungSPF serdisplib ShuttleVFD
	SimpleLCD T6963 TeakLCM Trefon ULA200 USBHUB USBLCD VNC WincorNixdorf X11
)

# Define the list of valid lcd4linux plugins.
# Some plugins were removed from this list:
# - imon: Uses telmond, which is only available on a fli4l router or an eisfair server.
# - ppp: It has been replaced by the netdev plugin.
# - seti: SETI@home software was replaced by sci-misc/boinc, which is not compatible.
# - xmms: XMMS software was replaced by media-sound/xmms2, which is not compatible.
IUSE_LCD4LINUX_PLUGINS=(
	apm asterisk button-exec cpuinfo dbus diskstats dvb exec event
	fifo file gps hddtemp huawei i2c-sensors iconv isdn kvv
	layout list loadavg meminfo mpd mpris-dbus menu mysql netdev netinfo pop3
	proc-stat python qnaplog raspi run sample statfs uname uptime
	w1retap wireless
)

# Add supported drivers from 'IUSE_LCD_DEVICES' to 'IUSE' and 'REQUIRED_USE'
REQUIRED_USE+=" || ( "
for LCD_DEVICE in "${IUSE_LCD_DEVICES[@]}"; do
	LCD_DEVICE=${LCD_DEVICE,,}
	IUSE+=" lcd_devices_${LCD_DEVICE} "
	REQUIRED_USE+=" lcd_devices_${LCD_DEVICE} "
done
REQUIRED_USE+=" ) "
unset LCD_DEVICE

# Add supported plugins from 'IUSE_LCD4LINUX_PLUGINS' to 'IUSE' and 'REQUIRED_USE'
IUSE+=" ${IUSE_LCD4LINUX_PLUGINS[*]} "
REQUIRED_USE+=" || ( ${IUSE_LCD4LINUX_PLUGINS[*]} ) "

# Define dependencies for all drivers in 'IUSE_LCD_DEVICES'
DEPEND_LCD_DEVICES="
	lcd_devices_astusb? ( virtual/libusb:0= )
	lcd_devices_bwct? ( virtual/libusb:0= )
	lcd_devices_curses? ( sys-libs/ncurses:0= )
	lcd_devices_dpf? ( virtual/libusb:0= )
	lcd_devices_g15? ( virtual/libusb:0= )
	lcd_devices_glcd2usb? ( virtual/libusb:0= )
	lcd_devices_irlcd? ( virtual/libusb:0= )
	lcd_devices_lcd2usb? ( virtual/libusb:0= )
	lcd_devices_ledmatrix? ( virtual/libusb:0= )
	lcd_devices_luise? (
		dev-libs/luise
		virtual/libusb:0=
	)
	lcd_devices_matrixorbitalgx? ( virtual/libusb:0= )
	lcd_devices_mdm166a? ( virtual/libusb:0= )
	lcd_devices_picolcd? ( virtual/libusb:0= )
	lcd_devices_picolcdgraphic? ( virtual/libusb:0= )
	lcd_devices_png? (
		media-libs/gd[png]
		media-libs/libpng:0=
	)
	lcd_devices_ppm? ( media-libs/gd )
	lcd_devices_samsungspf? ( virtual/libusb:0= )
	lcd_devices_serdisplib? ( dev-libs/serdisplib )
	lcd_devices_shuttlevfd? ( virtual/libusb:0= )
	lcd_devices_trefon? ( virtual/libusb:0= )
	lcd_devices_ula200? (
		dev-embedded/libftdi:1=
		virtual/libusb:0=
	)
	lcd_devices_usbhub? ( virtual/libusb:0= )
	lcd_devices_usblcd? ( virtual/libusb:0= )
	lcd_devices_vnc? ( net-libs/libvncserver )
	lcd_devices_x11? ( x11-libs/libX11 )
"

# Define dependencies for all plugins in 'IUSE_LCD4LINUX_PLUGINS'
DEPEND_LCD4LINUX_PLUGINS="
	asterisk? ( net-misc/asterisk )
	dbus? ( sys-apps/dbus )
	gps? ( dev-libs/nmeap )
	hddtemp? ( app-admin/hddtemp )
	iconv? ( virtual/libiconv )
	mpd? ( media-libs/libmpd )
	mpris-dbus? ( sys-apps/dbus )
	mysql? ( dev-db/mysql-connector-c:0= )
	python? ( ${PYTHON_DEPS} )
	wireless? (
		|| (
			net-wireless/iw
			net-wireless/wireless-tools
		)
	)
"

RDEPEND="
	dmalloc? ( dev-libs/dmalloc )
	${DEPEND_LCD_DEVICES}
	${DEPEND_LCD4LINUX_PLUGINS}
"

DEPEND="${RDEPEND}"

BDEPEND="sys-devel/autoconf-archive"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	default

	if use python; then
		# Shipped one is outdated and doesn't know python3, use system's instead.
		rm ax_python_devel.m4

		# Use correct python version.
		append-libs "-lpython${EPYTHON#python}$(usex python_single_target_${PYTHON_SINGLE_TARGET} '')"
	fi

	eautoreconf
}

src_configure() {
	# Enable all users enabled lcd devices
	local myeconfargs_lcd_devices
	for lcd_device in "${IUSE_LCD_DEVICES[@]}"; do
		if use "lcd_devices_${lcd_device,,}"; then
			myeconfargs_lcd_devices+=",${lcd_device}"
		fi
	done

	# Enable all users enabled lcd4linux plugins
	local myeconfargs_lcd4linux_plugins
	for lcd4linux_plugin in "${IUSE_LCD4LINUX_PLUGINS[@]}"; do
		if use "${lcd4linux_plugin}"; then
			myeconfargs_lcd4linux_plugins+=",${lcd4linux_plugin/-/_}"
		fi
	done

	local myeconfargs=(
		--disable-rpath
		$(use_with dmalloc)
		$(use_with outb)
		$(use_with python)
		$(use_with lcd_devices_x11 x)
		--with-drivers="${myeconfargs_lcd_devices#,}"
		--with-plugins="${myeconfargs_lcd4linux_plugins#,}"
		--x-include="/usr/include"
		--x-libraries="/usr/$(get_libdir)"
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# Install sample config, and must have 600, as lcd4linux checks this.
	insinto	/etc/lcd4linux
	insopts -m 0600
	doins lcd4linux.conf.sample

	newinitd "${FILESDIR}"/lcd4linux-r2.initd lcd4linux

	systemd_dounit "${FILESDIR}"/lcd4linux.service
}

pkg_postinst() {
	if [[ ! -z ${REPLACING_VERSIONS} ]]; then
		use python && einfo "Starting with that version, the python plugins uses now python3 instead if python2!"
	fi
}
