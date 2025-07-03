class Avactl < Formula
  desc "Avalara CLI Tool"
  homepage "https://avalara.com"
  # Point at your tap’s own GitHub archive as a dummy download
  url "https://github.com/ava-raas-tools/homebrew-tools/archive/refs/heads/main.tar.gz"
  sha256 :no_check
  version "latest"

  def install
    require "open3"

    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    base = "https://artifacts.platform.avalara.io/artifactory"
    meta = "#{base}/api/storage/phoenix-generic-local/avactl/#{arch}/darwin/?lastModified"

    ohai "Fetching latest avactl artifact metadata…"
    uri, _ = Open3.capture2("curl -sS #{meta.shellescape} | jq -r .uri")
    download_uri, _ = Open3.capture2("curl -sS #{(base + uri.strip).shellescape} | jq -r .downloadUri")

    mkdir "tmp"
    system "curl",      "-sL", download_uri.strip, "-o", "tmp/avactl.tar.gz"
    system "tar",       "-xzf",  "tmp/avactl.tar.gz",  "-C", "tmp"
    bin.install "tmp/avactl"
    system "xattr", "-dr", "com.apple.quarantine", bin/"avactl"
  end

  test do
    assert_match "version", shell_output("#{bin}/avactl --version")
  end
end
