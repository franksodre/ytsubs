module main

import entity { InfoPlaylist, PlaylistSubtitleCache }
import os
import time
import veb
import ytdlp
import ytdlp.urlparser as u

fn (app &App) post_playlist(mut ctx Context) veb.Result {
	mut watch := time.new_stopwatch()
	r := new_render()

	format := ctx.form['format']
	raw_url := ctx.form['url'] or { return ctx.request_error(is_valid_url_msg) }

	url := u.parse_url(raw_url) or {
		return ctx.html(r.display_error(err))
	}

	playlist_id := url.get_playlist_id() or {
		return ctx.request_error(r.display_error(err))
	}

	cache := app.cache()
	if item := cache.find_playlist(playlist_id, format) {
		if !os.is_dir_empty(item.path) {
			info := ytdlp.extract_playlist_info(url.raw_url) or {
				return ctx.html(r.display_error(err))
			}
			if info.len > 0 {
				return ctx.html(r.display_playlist(info.first(), item))
			}
		}
	}

	path := create_save_dir()
	watch.start()
	info_playlist := ytdlp.extract_playlist_info(url.raw_url) or {
		eprintln(err)
		return ctx.html(r.display_error(err))
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
	println('Downloading: ${watch.elapsed()}')

	item := PlaylistSubtitleCache{
		playlist_id: playlist_id
		format: format
		path: path
	}
	cache.save_playlist(item) or { eprintln(err) }

	return ctx.html(r.display_playlist(info_playlist.first(), item))
}
