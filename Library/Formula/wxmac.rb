require 'formula'

class Wxmac < Formula
  homepage "http://www.wxwidgets.org"
  url "https://downloads.sourceforge.net/project/wxwindows/3.0.0/wxWidgets-3.0.0.tar.bz2"
  sha1 "756a9c54d1f411e262f03bacb78ccef085a9880a"

  bottle do
    revision 4
    sha1 "509441d49e87c95cc9f7cef700b4426f3264ae0d" => :mavericks
    sha1 "70fca93b8c3e80a726ac700e7fcf155d89bc2172" => :mountain_lion
    sha1 "75f29a1fbbabced2f2fa1d0c83b85dc51bf71583" => :lion
  end

  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"

  # Upstream patch for starting non-bundled apps like gnuplot, see:
  # http://trac.wxwidgets.org/ticket/15613
  patch :p2 do
    url "http://trac.wxwidgets.org/changeset/75142/wxWidgets/trunk/src/osx/cocoa/utils.mm?format=diff&new=75142"
    sha1 "de67a8f8da479a5ab553d1c5444fc093975ff818"
  end

  def install
    # need to set with-macosx-version-min to avoid configure defaulting to 10.5
    # need to enable universal binary build in order to build all x86_64
    # FIXME I don't believe this is the whole story, surely this can be fixed
    # without building universal for users who don't need it. - Jack
    # headers need to specify x86_64 and i386 or will try to build for ppc arch
    # and fail on newer OSes
    # https://trac.macports.org/browser/trunk/dports/graphics/wxWidgets30/Portfile#L80
    ENV.universal_binary
    args = [
      "--disable-debug",
      "--prefix=#{prefix}",
      "--enable-shared",
      "--enable-unicode",
      "--enable-std_string",
      "--enable-display",
      "--with-opengl",
      "--with-osx_cocoa",
      "--with-libjpeg",
      "--with-libtiff",
      # Otherwise, even in superenv, the internal libtiff can pick
      # up on a nonuniversal xz and fail
      # https://github.com/Homebrew/homebrew/issues/22732
      "--without-liblzma",
      "--with-libpng",
      "--with-zlib",
      "--enable-dnd",
      "--enable-clipboard",
      "--enable-webkit",
      "--enable-svg",
      "--enable-mediactrl",
      "--enable-graphics_ctx",
      "--enable-controls",
      "--enable-dataviewctrl",
      "--with-expat",
      "--with-macosx-version-min=#{MacOS.version}",
      "--enable-universal_binary=#{Hardware::CPU.universal_archs.join(',')}",
      "--disable-precomp-headers",
      # This is the default option, but be explicit
      "--disable-monolithic"
    ]

    system "./configure", *args
    system "make install"
  end
end
