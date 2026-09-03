module main

import veb

import ytdlp
import os
import ytdlp.urlparser as u
import entity { InfoPlaylist, Info }
import time

fn (app &App) post_playlist(mut ctx Context) veb.Result {
	mut	watch := time.new_stopwatch()

	raw_url := ctx.form['url'] or { return ctx.request_error(is_valid_url_msg) }
	url := u.parse_url(raw_url) or {
		eprintln(err)
		return ctx.html("<div id='error'>${err}</div>")
	}

	// @known get_playlist_id also check if it's a playlist
	id := url.get_playlist_id() or {
		eprintln(err)
		return ctx.request_error('cannot get Playlist information. Please check the URL')
	}

	r := new_render()
	mut item, ok := app.cache().get_item[InfoPlaylist](id)
	if ok && !os.is_dir_empty(item.path) {
		// eprintln("HIT!")
		// eprintln("CACHED")
		return ctx.html(r.display(item))
	}

	path := create_save_dir()
	watch.start()
	info_playlist := ytdlp.extract_playlist_info(url.raw_url) or {
	 eprintln(err)
	 return ctx.html("<div id='error'>This Error will get better 2<div>") 
	}
	println("Info extraction: ${watch.elapsed().str()}")

	if info_playlist.len == 0 {
		return ctx.html("<div>Nothing found</div>")
	}

	watch.start()
	typ, err := ytdlp.download(url.raw_url, path)
	// TOOD(franksodre): put errors in a kind of global context so it can be used by Render to display it.
	// for now we just print it.
	if typ == .some_failed {
		eprintln(err)
	}
	println("Downloading: ${watch.elapsed().str()}")
	info_playlist.first().path = path
	app.cache().add_item[InfoPlaylist](id, info_playlist.first()) or {eprintln("Faild to cache item"); exit(1)}

	return ctx.html(r.display(info_playlist.first()))
}
