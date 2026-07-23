module ytdlp

import os
import config

pub fn create_sub(url string) os.Result {
	// "--write-subs"
	// "--sub-langs","en",
	res := os.exec([
		"yt-dlp",
		"--skip-download",
		// "--no-warnings"
		// "--ignore-errors"
		"--format", "best"
		"--write-auto-subs",
		// "--cookies-from-browser", "chrome"
		"--cookies", "${config.workdir}/cookies.txt"
		"-o", config.save_formatted, url
	])
	return res
}

// this should only be called when it's a playlist or create_sub should already handle that.
pub fn get_video_metadata(url string) string {
	res := os.exec([
		"yt-dlp"
		// "--ignore-errors"
		// "--no-warnings"
		"--flat-playlist"
		"--format", "best"
		// "--cookies-from-browser", "chrome"
		"--cookies", "${config.workdir}/cookies.txt"
		"-O", "%(.{id,title,original_url})#j,",
		url
	])
	return res.output
}

// fn read_cookies() string {
// 	cookie := os.read_file(config.workdir + "/assets/cookies.txt")or {eprintln(err); exit(1)}
// 	return cookie
// }
