EAPI="5"

JAVA_PKG_IUSE=""

inherit java-pkg-2 java-ant-2

DESCRIPTION="Google's phone number handling library, powering Android and more"
HOMEPAGE="https://code.google.com/p/libphonenumber"
#DEAD uses git now, but pre-7 vesions haven't been tagged
#ESVN_REPO_URI="http://libphonenumber.googlecode.com/svn/tags/${P}"
SRC_URI="http://www.snewbury.org.uk/libphonenumber-6.1.tar.xz"

LICENSE="APACHE-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""

CDEPEND="dev-java/junit:4"
DEPEND="${CDEPEND}
		>=virtual/jdk-1.6"
RDEPEND="${CDEPEND}
		 >=virtual/jre-1.6"

src_prepare() {
	 cd "${S}/lib"
     rm -v *.jar || die
     java-pkg_jar-from junit-4
}

src_install() {
	java-pkg_dojar build/jar/libphonenumber.jar 
	java-pkg_dojar build/jar/carrier-mapper.jar
	java-pkg_dojar build/jar/offline-geocoder.jar
}
