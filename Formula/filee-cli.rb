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

  on_macos do
    on_arm do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-1/filee-cli-2.0.0-1-osx-arm64.tar.gz"
      sha256 "6cc5434feaddabe75cae0a9d6ed4437534c80294ce2b2cf8f5a5ef04aa6b2088"
    end
    on_intel do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-1/filee-cli-2.0.0-1-osx-x64.tar.gz"
      sha256 "83eb2512b2c56310bbdb92cf1eb3d2c36c3b7acac5fdd6ebc6c43fb71960ca11"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-1/filee-cli-2.0.0-1-linux-arm64.tar.gz"
      sha256 "48bba4d22155304f068fb70394c1013a906d073577906fd430e6d1bc74b7029c"
    end
    on_intel do
      url "https://github.com/NomaDamas/filee-cli/releases/download/v2.0.0-1/filee-cli-2.0.0-1-linux-x64.tar.gz"
      sha256 "802aec45793625a36d4a16fdd07f63b844904261e3abcf85c3e47e5fe3f14eb9"
    end
  end

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+-\d+)$/i)
    strategy :github_latest
  end

  def install
    # The program looks for engines/ next to itself, so the whole folder stays together and bin/ links into it.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"filee-cli"
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
