class FileeCli < Formula
  desc "Unofficial CLI-only build of Filee: offline file converter for 255 formats"
  homepage "https://github.com/NomaDamas/filee-cli"
  version "2.0.0-1"
  license all_of: [
    "MIT",
    "GPL-3.0-or-later",
    "AGPL-3.0-or-later",
    "LGPL-2.1-or-later",
    "MPL-2.0",
  ]

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+-\d+)$/i)
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-1/filee-cli-2.0.0-1-osx-arm64.tar.gz",
          using: :nounzip
      sha256 "6cc5434feaddabe75cae0a9d6ed4437534c80294ce2b2cf8f5a5ef04aa6b2088"
    end
    on_intel do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-1/filee-cli-2.0.0-1-osx-x64.tar.gz",
          using: :nounzip
      sha256 "83eb2512b2c56310bbdb92cf1eb3d2c36c3b7acac5fdd6ebc6c43fb71960ca11"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-1/filee-cli-2.0.0-1-linux-arm64.tar.gz",
          using: :nounzip
      sha256 "48bba4d22155304f068fb70394c1013a906d073577906fd430e6d1bc74b7029c"
    end
    on_intel do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-1/filee-cli-2.0.0-1-linux-x64.tar.gz",
          using: :nounzip
      sha256 "802aec45793625a36d4a16fdd07f63b844904261e3abcf85c3e47e5fe3f14eb9"
    end
  end

  # The packages hold vendor bundles (LibreOffice.app, calibre.app, FFmpeg, ...) signed by their makers, which must
  # stay byte-identical. Homebrew rewrites the install names of every Mach-O file in a keg: that fails on some of
  # these files and breaks the signature of the others. So the keg holds the SHA-256-checked archive and the steps
  # below unpack it after Homebrew's linkage pass, which then has nothing to touch.
  def install
    # One fixed name, so the steps below need no logic: the archive is whichever package this platform downloaded.
    libexec.install Dir["*.tar.gz"].first => "package.tar.gz"
    (bin/"filee-cli").write <<~SH
      #!/bin/sh
      exec "#{opt_libexec}/filee-cli" "$@"
    SH
    (bin/"filee-cli").chmod 0555
  end

  post_install_steps do
    run "/usr/bin/tar", args: ["-xzf", "{{libexec}}/package.tar.gz", "--strip-components=1", "-C", "{{libexec}}"]
    remove "libexec/package.tar.gz", base: :prefix
  end

  def caveats
    <<~EOS
      This is an unofficial redistribution of Filee's command line, not made or endorsed by its author.
      Engines (FFmpeg, Ghostscript, LibreOffice, calibre, Pandoc) are bundled under engines/ with their sources
      offered in the release assets; see #{libexec}/THIRD-PARTY-NOTICES.md.
      On Linux, calibre needs: libxcb1 libxkbcommon0 libfontconfig1 libfreetype6 libx11-6 libegl1 libopengl0 libglx0,
      and HWP to PDF needs a Korean font (for example fonts-noto-cjk).
    EOS
  end

  test do
    assert_match "filee #{version.to_s.split("-").first}", shell_output("#{bin}/filee-cli version")
    (testpath/"in.md").write("# Hello\n\nfilee-cli test\n")
    system bin/"filee-cli", "convert", testpath/"in.md", "--to", "html"
    assert_match "filee-cli test", (testpath/"in.html").read
  end
end
