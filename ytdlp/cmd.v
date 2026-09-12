// @disgusting this is terrible
// @No errors any more
module ytdlp

import os
import config

// Don't like it but yeah...
fn build_args(url string, format string, path string) string {
	cmd := 'yt-dlp \\
	--ignore-errors \\
	--no-warnings \\
	--skip-download \\
	--remote-components ejs:github \\
	--write-auto-subs \\
	--sub-format ${format} \\
	--convert-subs ${format} \\
	--cookies ${config.workdir}/cookies.txt -o "${path + "%(title)s.%(ext)s"}" "${url}"'
	return cmd
}

// We don't want erros during extraction
fn build_info_args(url string) string { 
	cmd := '
		yt-dlp \\
		--flat-playlist \\
		--ignore-errors \\
		--no-warnings \\
		--remote-components ejs:github \\
		--cookies ${config.workdir}/cookies.txt 2>/dev/null\\
		-j "${url}" | jq -s "group_by(.id) |
		map({id: .[0].id, title: .[0].title,
		duration: .[0].duration_string, url: .[0].original_url,language: .[0].language})"'
		return cmd
}

// We don't want erros during extraction
fn build_info_args_playlist(url string) string { 
	cmd := '
		yt-dlp \\
		--flat-playlist \\
		--ignore-errors \\
		--no-warnings \\
		--remote-components ejs:github \\
		--cookies ${config.workdir}/cookies.txt 2>/dev/null\\
		-j "${url}" | jq -s "group_by(.playlist_id) | map({playlist_id:
		.[0].playlist_id, playlist_title: .[0].playlist_title,video:
		map({title:.title,id:.id,duration:.duration_string,url:.original_url,language:.language
		})})"'
		return cmd
}

pub struct DownloadParams {
pub:
	url 		string
	format 	string = "srt"
	path		string = config.save_formatted
}

pub fn download_cmd(params DownloadParams) os.Result {
	args := build_args(params.url, params.format, params.path)
	res := os.execute(args)
	return res
}
fn extract_info_cmd(rawurl string) !string {
	mut args := build_info_args(rawurl)
	res := os.execute(args)
	return res.output
}

fn extract_info_playlist_cmd(rawurl string) !string {
	mut args := build_info_args_playlist(rawurl)
	res := os.execute(args)
	return res.output
}
