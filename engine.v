module main

import os
import config

fn create_sub(input string) ! {
	res := os.exec([
	"yt-dlp",
	"--skip-download",
	"--write-auto-subs",
	// "--sub-langs","en",
	"-o", config.save_formatted, input])
	println(res)
}
