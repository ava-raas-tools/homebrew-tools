class Avactl < Formula
  desc "Avalara CLI Tool"
  homepage "https://avalara.com"
  version "0.1.0"

  stable do
    url "https://github.com/ava-raas-tools/homebrew-tools/archive/refs/tags/v0.1.0.tar.gz"
    sha256 "c90be3185116d9eb6861b5a783b3a3feafa7c07631b73ef90c1063929cbfb81d"
  end

  def install
    require "net/http"
    require "uri"
    require "json"

    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    base = "https://artifacts.platform.avalara.io/artifactory"
    # 1) List the dir, get the folder URI
    metadata_url = "#{base}/api/storage/phoenix-generic-local/avactl/#{arch}/darwin/?lastModified"
    ohai "Fetching artifact metadata…"
    list = JSON.parse(Net::HTTP.get(URI(metadata_url)))
    folder_uri = list.fetch("uri")

    # 2) Fetch that folder’s JSON to get the actual downloadUri
    file_meta = JSON.parse(Net::HTTP.get(URI(base + folder_uri)))
    download_url = file_meta.fetch("downloadUri")

    # 3) Download, extract, install
    tmp = buildpath/"tmp"
    tmp.mkpath
    system "curl", "-sL", download_url, "-o", tmp/"avactl.tar.gz"
    system "tar",  "-xzf",  tmp/"avactl.tar.gz", "-C", tmp
    bin.install tmp/"avactl"
    system "xattr", "-dr", "com.apple.quarantine", bin/"avactl"
  end

  test do
    # The output should include "0.1.0" now
    assert_match "0.1.0", shell_output("#{bin}/avactl --version")
  end
end
