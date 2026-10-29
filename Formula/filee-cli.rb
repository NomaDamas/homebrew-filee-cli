class FileeCli < Formula
  desc "Unofficial CLI-only build of Filee: offline file converter for 255 formats"
  homepage "https://github.com/NomaDamas/filee-cli"
  version "2.0.0-4"
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
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-4/filee-cli-2.0.0-4-osx-arm64.tar.gz",
          using: :nounzip
      sha256 "daeaed01f6502cb80b91f087e1b2cf2316b83b8b54b2893e2acc58dcf53d9021"
    end
    on_intel do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-4/filee-cli-2.0.0-4-osx-x64.tar.gz",
          using: :nounzip
      sha256 "8cbb11eb81f14f1a8628faafaab967035039b5da32fd0b26effc25359ffb1ecf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-4/filee-cli-2.0.0-4-linux-arm64.tar.gz",
          using: :nounzip
      sha256 "3eddc528f1c8c2d2e7d31a59d27f0b180474f2deaebb92bd01a578eda56d0a98"
    end
    on_intel do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-4/filee-cli-2.0.0-4-linux-x64.tar.gz",
          using: :nounzip
      sha256 "2f8186be85746e41eb73b9e7850b18d271f2cf262d02c79d573a587e9404bfb0"
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
    # filee-cli keeps its settings in a data folder; the test sandbox does not allow writing to the home folder.
    ENV["FILEE_DATA_DIR"] = testpath/"data"
    assert_match "filee #{version.to_s.split("-").first}", shell_output("#{bin}/filee-cli version")
    (testpath/"in.md").write("# Hello\n\nfilee-cli test\n")
    system bin/"filee-cli", "convert", testpath/"in.md", "--to", "html"
    assert_match "filee-cli test", (testpath/"in.html").read
  end
end
