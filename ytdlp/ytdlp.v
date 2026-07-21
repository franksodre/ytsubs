module ytdlp

import os
import config

pub fn create_sub(url string) os.Result {
	// "--write-subs"
	// "--sub-langs","en",
	res := os.exec([
		config.ytdlp_bin
		"--skip-download",
		"--no-warnings"
		"--write-auto-subs",
		"--no-check-certificate"
		"--cookies", config.cookies
		"-o", config.save_formatted, url
	])
	return res
}

// this should only be called when it's a playlist or create_sub should already handle that.
pub fn get_video_metadata(url string) string {
	res := os.exec([
		config.ytdlp_bin
		"--ignore-errors"
		"--no-warnings"
		"--flat-playlist"
		"--no-check-certificate"
		"--cookies", config.cookies
		"-O", "%(.{id,title,original_url})#j,",
		url
	])
	return res.output
}
