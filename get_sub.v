// @disgusting in all the things that disgust me this is the worst and
// sam altman he really give me the creepies
module main

import entity { Info }
import os
import time
import veb
import ytdlp
import ytdlp.urlparser as u

const is_valid_url_msg = 'field URL cannot be empty. Please enter a valid YT URL'
const video_id_msg = 'cannot get video information. Please check the URL'

@['/'; post]
fn (app &App) post(mut ctx Context) veb.Result {
	mut watch := time.new_stopwatch()

	r := new_render()

	format := ctx.form['format']
	raw_url := ctx.form['url'] or {
		return ctx.request_error(is_valid_url_msg)
	}

	url := u.parse_url(raw_url) or {
		return ctx.html(r.display_error(err))
	}

	if url.is_playlist() {
		return app.post_playlist(mut ctx)
	}

	id := url.get_video_id() or {
		eprintln(err)
		return ctx.request_error(video_id_msg)
	}
	mut item, ok := app.cache().get_item[Info](id, format)

	// this is a temporary fix
	if ok && !os.is_dir_empty(item.path) {
		return ctx.html(r.display(item))
	}

	path := create_save_dir()
	info := ytdlp.extract_info(url.raw_url) or {
		eprintln(err)
		return ctx.html(r.display_error(err))
	}
	if info.len == 0 {
		return ctx.html(r.display_warn_string("Nothing found. Video doesn't exits or Private"))
	}

	watch.start()
	_, err := ytdlp.download(ytdlp.DownloadParams{ url: url.raw_url, path: path, format: format })
	eprintln(err) // TODO(franksodre): render it later.
	println('Downloading: ${watch.elapsed().str()}') // measuring

	info.first().path = path
	info.first().format = format
	app.cache().add_item[Info](id, format, info.first()) or { eprintln(err) }

	return ctx.html(r.display(info.first()))
}
