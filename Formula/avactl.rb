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
    base_url = "https://artifacts.platform.avalara.io/artifactory"
    # 1) list folder metadata (sorted by lastModified by default)
    meta_url = "#{base_url}/api/storage/phoenix-generic-local/avactl/#{arch}/darwin/?lastModified"
    ohai "Fetching artifact metadata…"
    meta = JSON.parse(Net::HTTP.get(URI(meta_url)))
    folder_uri = meta.fetch("uri")

    # 2) fetch that folder’s metadata to get the downloadUri
    file_meta = JSON.parse(Net::HTTP.get(URI(base_url + folder_uri)))
    download_url = file_meta.fetch("downloadUri")

    # 3) download/extract/install
    tmp = buildpath/"tmp"
    tmp.mkpath
    system "curl", "-sL", download_url, "-o", tmp/"avactl.tar.gz"
    system "tar",  "-xzf",  tmp/"avactl.tar.gz",  "-C", tmp
    bin.install tmp/"avactl"
    system "xattr", "-dr", "com.apple.quarantine", bin/"avactl"
  end

  test do
    assert_match "0.1.0", shell_output("#{bin}/avactl --version")
  end
end
