// @disgusting in all the things that disgust me this is the worst and
// sam altman he really give me the creepies
module main

import veb

import ytdlp
import ytdlp.urlparser as u
import entity {Info, InfoPlaylist}
import os

import time

const is_valid_url_msg = 'field URL cannot be empty. Please enter a valid YT URL'
const video_id_msg = 'cannot get video information. Please check the URL'

@['/'; post]
fn (app &App) post(mut ctx Context) veb.Result {
	mut watch := time.new_stopwatch()

	format := ctx.form['format']
	raw_url := ctx.form['url'] or { return ctx.request_error(is_valid_url_msg) }
	url := u.parse_url(raw_url) or { return ctx.html("<div>${err}</div>") }

	if url.is_playlist() {
		return app.post_playlist(mut ctx)
	}
	id := url.get_video_id() or {
		eprintln(err)
		return ctx.request_error(video_id_msg)
	}
	// currently cache doesn't check whether the file exists in the filesystem or not
	// but it should
	r := new_render()
	mut item, ok := app.cache().get_item[Info](id)
	// tmp
	if ok && !os.is_dir_empty(item.path) {
		eprintln("HIT!")
		eprintln("CACHED")
		return ctx.html(r.display(item))
	}

	path := create_save_dir()
	info := ytdlp.extract_info(url.raw_url) or {
	 eprintln(err)
	 return ctx.html("<div id='error'>This Error will get better 2<div>") 
	}
	if info.len == 0 {
		return ctx.html("<div class='text-amber-300 font-medium'><span
		class='bg-amber-300 text-white font-bold px-2 rounded mr-2'>!</span>Nothing
		found. Video doesn't exits or Private</div>")
	}

	watch.start()
	_, err := ytdlp.download(ytdlp.DownloadParams{url: url.raw_url, path: path, format: format})
	eprintln(err)
	// TOOD(franksodre): put errors in a kind of global context so it can be used by Render to display it.
	// for now we just print it.
	println("Downloading: ${watch.elapsed().str()}") // measuring
	info.first().path = path
	info.first().format = format
	println(format)
	app.cache().add_item[Info](id, info.first()) or {eprintln(err)}

	return ctx.html(r.display(info.first()))
}
