module main

import entity { Info, SubtitleCache }
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

	video_id := url.get_video_id() or {
		eprintln(err)
		return ctx.request_error(video_id_msg)
	}

	cache := app.cache()
	if item := cache.find_video(video_id, format) {
		if !os.is_dir_empty(item.path) {
			info := ytdlp.extract_info(url.raw_url) or {
				return ctx.html(r.display_error(err))
			}
			if info.len > 0 {
				return ctx.html(r.display(info.first(), item))
			}
		}
	}

	path := create_save_dir()
	info := ytdlp.extract_info(url.raw_url) or {
		 eprintln(err)
		return ctx.html(r.display_error(err))
	}
	if info.len == 0 {
		return ctx.html(r.display_warn_string("Nothing found. Video doesn't exist or is private"))
	}

	watch.start()
	_, err := ytdlp.download(ytdlp.DownloadParams{url: url.raw_url, path: path, format: format})
	eprintln(err)
	println('Downloading: ${watch.elapsed()}')

	item := SubtitleCache{
		video_id: video_id
		format: format
		path: path
	}
	cache.save_video(item) or { eprintln(err) }

	return ctx.html(r.display(info.first(), item))
}
