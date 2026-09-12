module main

import veb
import ytdlp
import os
import ytdlp.urlparser as u
import entity { InfoPlaylist, Info }
import time

fn (app &App) post_playlist(mut ctx Context) veb.Result {
	mut watch := time.new_stopwatch()
	r := new_render()

	format := ctx.form['format']
	raw_url := ctx.form['url'] or { return ctx.request_error(is_valid_url_msg) }

	url := u.parse_url(raw_url) or {
		eprintln(err)
		return ctx.html(r.display_error(err))
	}

	// @known get_playlist_id also check if it's a playlist
	id := url.get_playlist_id() or {
		return ctx.request_error(r.display_error(err))
	}

	mut item, ok := app.cache().get_item[InfoPlaylist](id, format)
	if ok && !os.is_dir_empty(item.path) {
		return ctx.html(r.display(item))
	}

	path := create_save_dir()
	watch.start()
	mut info_playlist := ytdlp.extract_playlist_info(url.raw_url) or {
		eprintln(err)
		return ctx.html(r.display_error_string("<div id='error'>This Error will get better 2<div>"))
	}

	println('Info extraction: ${watch.elapsed()}')

	if info_playlist.len == 0 {
		return ctx.html(r.display_warn_string("Nothing found. Playlist empty or not visible"))
	}

	watch.start()
	_, err := ytdlp.download(ytdlp.DownloadParams{
		url: url.raw_url
		format: format
		path: path
	})
	eprintln(err)
	// TOOD(franksodre): put errors in a kind of global context so it can be used by Render to display it.
	// for now we just print it.
	println('Downloading: ${watch.elapsed()}')

	info_playlist.first().path = path
	info_playlist.first().video_format = format
	app.cache().add_item[InfoPlaylist](id, format, info_playlist.first()) or { eprintln(err) }

	return ctx.html(r.display(info_playlist.first()))
}
