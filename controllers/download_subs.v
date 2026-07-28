module controllers

import veb
import config

// /subs/:id
@['/subs/:filename'; get]
fn (app &App) download(mut ctx Context, filename string) veb.Result {
		file := config.save_dir + filename
		ctx.set_content_type("text/vtt")
		return ctx.file(file)
}
