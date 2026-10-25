// vfmt off
module main

import veb
import config
import encoding.base64
import os

// /subs/:id
@['/download/sub'; get]
fn (app &App) download(mut ctx Context) veb.Result {
	name := ctx.query['name'] or { '' }

	file_name := base64.url_decode_str(name)
	file := os.join_path_single(config.save_dir, file_name)
	ctx.set_content_type("text/vtt")
	return ctx.file(file)
}
