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
    base_artifactory_url = "https://artifacts.platform.avalara.io/artifactory"

    # 1) Fetch metadata for the latest binary
    meta_url = "#{base_artifactory_url}/api/storage/phoenix-generic-local/avactl/#{arch}/darwin/?lastModified"
    ohai "Fetching artifact metadata…"
    metadata = JSON.parse(Net::HTTP.get(URI(meta_url)))

    # 2) Use the full URI from metadata to fetch file metadata
    file_uri = metadata.fetch("uri")
    ohai "Fetching file metadata…"
    file_meta = JSON.parse(Net::HTTP.get(URI(file_uri)))
    download_url = file_meta.fetch("downloadUri")
    odie "downloadUri missing!" if download_url.to_s.empty?

    # 3) Download and extract the binary
    tmp = buildpath/"tmp"
    tmp.mkpath
    ohai "Downloading avactl from #{download_url}"
    system "curl", "-sL", download_url, "-o", tmp/"avactl.tar.gz"
    system "tar",  "-xzf",  tmp/"avactl.tar.gz",  "-C", tmp

    # 4) Install and remove quarantine attribute
    bin.install tmp/"avactl"
    system "xattr", "-dr", "com.apple.quarantine", bin/"avactl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/avactl --version")
  end
end
