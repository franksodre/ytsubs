module ytdlp

import os
import config
/*
	 --no-playlist
	 Download only the video, if the URL refers to a video and a playlist

	 --skip-playlist-after-errors N
	 Number of allowed failures until the rest of the playlist is skipped

	 --lazy-playlist
	 Process entries in the playlist as they are received.  This disables n_entries, --playlist-random and --playlist-reverse

	 --write-playlist-metafiles
	 Write playlist metadata in addition to the video metadata when using --write-info-json, --write-description etc.  (default)

	 --no-write-playlist-metafiles
	 Do not write playlist metadata when using --write-info-json, --write-description etc.

	 =n_entries (numeric): Total number of extracted items in the playlist

	 =playlist_id (string): Identifier of the playlist that contains the video
*/

pub fn yt_generate_sub(url string, path ?string) os.Result {
	p := path or { config.save_formatted }
	res := os.exec([
		"yt-dlp",
		"--skip-download",
		"--no-warnings"
		"--ignore-errors"
		"--remote-components", "ejs:github"
		"--write-auto-subs",
		"--cookies", "${config.workdir}/cookies.txt"
		"-o", p, url
	])
	return res
}

// this should only be called when it's a playlist or create_sub should already handle that.
pub fn yt_get_metadata(url string) string {
	res := os.exec([
		"yt-dlp"
		"--ignore-errors"
		"--no-warnings"
		"--flat-playlist"
		"--remote-components", "ejs:github"
		"--cookies", "${config.workdir}/cookies.txt"
		"-O", "%(.{id,title,original_url,n_entries})#j,",
		url
	])
	return res.output
}

pub fn list_formats(url string) string {
	println("LIST OF FORMATS::")
	res := os.exec([
		"yt-dlp"
		"--list-formats"
		url
	])
	return res.output
}
