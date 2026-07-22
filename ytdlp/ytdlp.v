module ytdlp

import os
import config

pub fn create_sub(url string) os.Result {
	cookie := read_cookies()
	// "--write-subs"
	// "--sub-langs","en",
	res := os.exec([
		"yt-dlp",
		"--skip-download",
		"--no-warnings"
		"--write-auto-subs",
		// "--cookies-from-browser", "chrome"
		"--cookies", "${cookie}"
		"-o", config.save_formatted, url
	])
	return res
}

// this should only be called when it's a playlist or create_sub should already handle that.
pub fn get_video_metadata(url string) string {
	cookie := read_cookies()
	res := os.exec([
		"yt-dlp"
		"--ignore-errors"
		"--no-warnings"
		"--flat-playlist"
		// "--cookies-from-browser", "chrome"
		"--cookies", "${cookie}"
		"-O", "%(.{id,title,original_url})#j,",
		url
	])
	return res.output
}

fn read_cookies() string {
	cookie := os.read_file("./cookies") or {eprintln(err); exit(1)}
	return cookie
}
