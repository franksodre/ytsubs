module main

import veb
import config

// /subs/:id
@['/download/sub'; get]
fn (app &App) download(mut ctx Context) veb.Result {
		dir := ctx.query['d'] or { '' }
		name := ctx.query['name'] or {''}

		file := config.save_dir + dir + '/' + name
		ctx.set_content_type("text/vtt")
		return ctx.file(file)
}
