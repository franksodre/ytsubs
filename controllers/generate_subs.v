module controllers

import veb
import os
import config
import ytdlp
import strings

@['/'; get]
fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.html($tmpl('../templates/index.html'))
}

@['/'; post]
fn (app &App) post(mut ctx Context) veb.Result {
	url := ctx.form['url'] or {
		return ctx.request_error('The url field cannot be empty. Please try to enter an url (you can copy a youtube link)')
	}
	mut sb := strings.new_builder(100)

	// g := ytdlp.new_general(url)
	metadata := ytdlp.get_sub_metadata(url) or {return ctx.html("<div id='error'>Error<div>")}
	data, failed := metadata.generate()


	// handle_video should already tell if it's a playlist or not.
	// It also should only return the downloadable subs.
	// subs := handle_video(metadata)

	entries := os.ls(config.save_dir) or { [] }

	if subs.len > 1 {
		sb.write_string('<div>')
		for k, entry in entries {
			sb.write_string(view_html_download(entry, data[k].title))
		}
		sb.write_string('</div><br><br>')
		
		return ctx.html(sb.str())
	}
	if failed.len > 1 {

	}
	sb.write_string('<div>')

	for k, entry in entries {
		sb.write_string(view_html_download(entry, data[k].title))
	}
	sb.write_string('</div><br>')
	return ctx.html(sb.str())
}
