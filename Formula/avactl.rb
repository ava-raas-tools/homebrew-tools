class Avactl < Formula
  desc "Avalara CLI Tool"
  homepage "https://avalara.com"
  version "1.0.0"

  # Dummy static tarball URL — Homebrew requires this even if unused
  url "https://github.com/Homebrew/homebrew-core/archive/refs/tags/1.0.tar.gz"
  sha256 "d4c9f00394815a813e8a48f4a027a087594548b5a5ae44507a826ec80f6b6a1e"

  def install
    require "open3"

    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    base_url = "https://artifacts.platform.avalara.io/artifactory"
    metadata_url = "#{base_url}/api/storage/phoenix-generic-local/avactl/#{arch}/darwin/?lastModified"

    ohai "Fetching latest avactl artifact metadata..."
    stdout, _ = Open3.capture2("curl -sS \"#{metadata_url}\" | jq -r .uri")
    latest_uri = stdout.strip

    stdout, _ = Open3.capture2("curl -sS \"#{base_url}#{latest_uri}\" | jq -r .downloadUri")
    download_url = stdout.strip

    mkdir "tmp"
    system "curl", "-sL", download_url, "-o", "tmp/avactl.tar.gz"
    system "tar", "-xzf", "tmp/avactl.tar.gz", "-C", "tmp"
    bin.install "tmp/avactl"
    system "xattr", "-dr", "com.apple.quarantine", bin/"avactl"
  end

  test do
    system "#{bin}/avactl", "--version"
  end
end
