#!/bin/sh
set -eu

version="0.1.0"
release_base="https://github.com/dhanh-ryuu/machine-lives-matter-distribution/releases/download/cli-v${version}"

case "$(uname -s)" in
  Darwin) os="darwin" ;;
  Linux) os="linux" ;;
  *) echo "Unsupported operating system: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

archive="mlm_${version}_${os}_${arch}.tar.gz"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT INT TERM

echo "Downloading mlm ${version} for ${os}/${arch}..."
curl -fsSL "${release_base}/${archive}" -o "${tmp_dir}/${archive}"
curl -fsSL "${release_base}/checksums.txt" -o "${tmp_dir}/checksums.txt"

expected="$(awk -v file="$archive" '$2 == file { print $1 }' "${tmp_dir}/checksums.txt")"
if [ -z "$expected" ]; then echo "No checksum found for ${archive}" >&2; exit 1; fi
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "${tmp_dir}/${archive}" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "${tmp_dir}/${archive}" | awk '{print $1}')"
fi
if [ "$actual" != "$expected" ]; then echo "Checksum verification failed" >&2; exit 1; fi

tar -xzf "${tmp_dir}/${archive}" -C "$tmp_dir"
install_dir="${MLM_INSTALL_DIR:-/usr/local/bin}"
if [ -z "${MLM_INSTALL_DIR:-}" ] && [ ! -w "$install_dir" ]; then install_dir="${HOME}/.local/bin"; fi
mkdir -p "$install_dir"
install -m 0755 "${tmp_dir}/mlm" "${install_dir}/mlm"
echo "Installed mlm to ${install_dir}/mlm"
case ":${PATH}:" in *":${install_dir}:"*) ;; *) echo "Add ${install_dir} to your PATH before running mlm." ;; esac
echo "Run: mlm doctor"
