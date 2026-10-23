class FileeCli < Formula
  desc "Unofficial CLI-only build of Filee: offline file converter for 255 formats"
  homepage "https://github.com/NomaDamas/filee-cli"
  version "2.0.0-3"
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
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-3/filee-cli-2.0.0-3-osx-arm64.tar.gz",
          using: :nounzip
      sha256 "e5e277e02a200001b2d7e0f63b5039497b1be99354f32e9ff534a4b0286088cc"
    end
    on_intel do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-3/filee-cli-2.0.0-3-osx-x64.tar.gz",
          using: :nounzip
      sha256 "255d3f06d7df4ad367d99d63cbe542c2cda8b86fef071141c5cf52be973939de"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-3/filee-cli-2.0.0-3-linux-arm64.tar.gz",
          using: :nounzip
      sha256 "07123e5cab6fb15a07c493e819635906c0eb4a50cfa54aea53b32b1cb557ce7c"
    end
    on_intel do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-3/filee-cli-2.0.0-3-linux-x64.tar.gz",
          using: :nounzip
      sha256 "3388a2a33b5dea7eec97a35e180073e3e395c52749e0933d8d7bb5709a05b463"
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
