module main

import veb
import config
import encoding.base64
import os

@['/download/sub'; get]
fn (app &App) download(mut ctx Context) veb.Result {
	dir := ctx.query['d'] or { '' }
	name := ctx.query['name'] or { '' }
	decoded_name := base64.url_decode_str(name)

	// Both values originate from our renderer. Keep them as single path
	// components so a crafted request cannot escape the save directory.
	if dir == '' || os.file_name(dir) != dir || dir == '.' || dir == '..' {
		return ctx.not_found()
	}
	if decoded_name == '' || os.file_name(decoded_name) != decoded_name {
		return ctx.not_found()
	}

	file := os.join_path(config.save_dir, dir, decoded_name)
	if !os.is_file(file) {
		return ctx.not_found()
	}

	ctx.set_content_type(content_type(os.file_ext(file)))
	return ctx.file(file)
}

fn content_type(ext string) string {
	return match ext {
		'.vtt' { 'text/vtt' }
		'.srt' { 'application/x-subrip' }
		'.ass' { 'text/x-ass' }
		else { 'application/octet-stream' }
	}
}
