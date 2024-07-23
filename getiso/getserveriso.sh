#!/bin/sh

echo_ok() { printf "%b%s%b" "${GREEN}[+]${NC} " "$1" "\n" >&2; }
echo_info() { printf "%b%s%b" "${BLUE}[i]${NC} " "$1" "\n" >&2; }
echo_err() { printf "%b%s%b" "${RED}[!]${NC} " "$1" "\n" >&2; }

# Download enterprise evaluation Windows versions

windows_version="windows-server-2022"
enterprise_type="server"

url="https://www.microsoft.com/en-us/evalcenter/download-$windows_version"

iso_download_page_html="$(curl --location --max-filesize 1M --fail --proto =https --tlsv1.2 --http1.1 -- "$url")" || {
    handle_curl_error $?
    return $?
}

if ! [ "$iso_download_page_html" ]; then
    # This should only happen if there's been some change to where this download page is located
    echo_err "Windows enterprise evaluation download page gave us an empty response"
    return 1
fi

iso_download_links="$(echo "$iso_download_page_html" | grep -o "https://go.microsoft.com/fwlink/p/?LinkID=[0-9]\+&clcid=0x[0-9a-z]\+&culture=en-us&country=US")" || {
    # This should only happen if there's been some change to the download endpoint web address
    echo_err "Windows enterprise evaluation download page gave us no download link"
    return 1
}

# Limit untrusted size for input validation
iso_download_links="$(echo "$iso_download_links" | head -c 1024)"

case "$enterprise_type" in
    # Select x64 download link
    "enterprise") iso_download_link=$(echo "$iso_download_links" | head -n 2 | tail -n 1) ;;
    # Select x64 LTSC download link
    "ltsc") iso_download_link=$(echo "$iso_download_links" | head -n 4 | tail -n 1) ;;
    *) iso_download_link="$iso_download_links" ;;
esac

# Follow redirect so proceeding log message is useful
# This is a request we make this Fido doesn't
# We don't need to set "--max-filesize" here because this is a HEAD request and the output is to /dev/null anyway
iso_download_link="$(curl --location --output /dev/null --silent --write-out "%{url_effective}" --head --fail --proto =https --tlsv1.2 --http1.1 -- "$iso_download_link")" || {
    # This should only happen if the Microsoft servers are down
    handle_curl_error $?
    return $?
}

# Limit untrusted size for input validation
iso_download_link="$(echo "$iso_download_link" | head -c 1024)"

echo "$iso_download_link"