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

    # 1) List the directory, filtering out folders, sorted by lastModified
    folder_url = "#{base}/api/storage/phoenix-generic-local/avactl/#{arch}/darwin/?lastModified&listFolders=0"
    ohai "Fetching avactl folder metadata…"
    list = JSON.parse(Net::HTTP.get(URI(folder_url)))
    children = list.fetch("children")
    odie "No avactl binaries found!" if children.empty?

    # 2) Take the first child (most recently modified) URI
    file_uri = children.first.fetch("uri")

    # 3) Fetch that file's metadata to get the downloadUri
    file_meta_url = "#{base}/api/storage#{file_uri}"
    ohai "Fetching avactl file metadata…"
    file_meta = JSON.parse(Net::HTTP.get(URI(file_meta_url)))
    download_url = file_meta.fetch("downloadUri")

    # 4) Download, extract, install
    tmp = buildpath/"tmp"
    tmp.mkpath
    ohai "Downloading avactl from #{download_url}"
    system "curl", "-sL", download_url, "-o", tmp/"avactl.tar.gz"
    system "tar",  "-xzf",  tmp/"avactl.tar.gz",  "-C", tmp
    bin.install tmp/"avactl"
    system "xattr", "-dr", "com.apple.quarantine", bin/"avactl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/avactl --version")
  end
end
