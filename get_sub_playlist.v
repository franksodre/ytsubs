// use a proper logger
module main

import veb
import ytdlp
import os
import ytdlp.urlparser as u
import entity { InfoPlaylist, PlaylistSubtitleCache }
import encoding.base64

struct CachedFile {
	filepath string
	encoded string
}

fn info_to_subtitle_playlist_cache(info_playlist InfoPlaylist, path string, format string) PlaylistSubtitleCache {
	item := PlaylistSubtitleCache {
		playlist_id: info_playlist.playlist_id
		format: format
		path: path
	}
	return item
}

fn (app &App) post_playlist(mut ctx Context) veb.Result {
	format := ctx.form['format']
	raw_url := ctx.form['url'] or { return ctx.request_error('Please submit a url!') }

	url := u.parse_url(raw_url) or {
		// ctx.res.set_status()
		eprintln(err)
		return ctx.request_error('URL malformed!')
	}

	id := url.get_playlist_id() or {
		eprintln(err)
		return ctx.request_error(err.msg())
	}

	mut playlist_json := ytdlp.extract_playlist_info(url.raw_url) or {
		// ctx.res.set_status(.internal_sever_error)
		eprintln(err)
		return ctx.server_error('Something wrong as happened, try again later!')
	}

	info_playlist := playlist_json.first()
	cached := app.cache().find_playlist(id, format) or {
		return download_sub_playlist(app, mut ctx, info_playlist, format)
	}

	if os.is_dir_empty(cached.path) {
		eprintln('on is_dir_empty::cached.path == `${cached.path}`')
		return ctx.text('Nothing to render!')
	}


	mut cached_files := []CachedFile{}

	ext := '.' + format
	filepaths := os.ls(cached.path) or { eprintln(err); exit(1) }.filter(os.file_ext(it) == ext)

	for _, p in filepaths {
		filepath := get_filepath_from_path(cached.path, p)
		path_encoded := base64.url_encode_str(filepath)
		cached_files << CachedFile{filepath: get_filename(p), encoded: path_encoded}
	}

	errors := []ytdlp.ParserError{}
	return $veb.html('./templates/partials/results_playlist.html')
}

fn download_sub_playlist(app &App, mut ctx Context, info_playlist InfoPlaylist, format string) veb.Result {
	// this could somehow fail?
	path := create_save_dir()

	errors := ytdlp.download(url: info_playlist.playlist_url, format: format, path: path)

	// this is not cool but I don't know how to reproduce the errors
	if errors.len == 0 {
		subtitle := info_to_subtitle_playlist_cache(info_playlist, path, format)
		app.cache().save_playlist(subtitle) or { 
			eprintln(err)
		}
	}


	mut cached_files := []CachedFile{}

	ext := '.' + format
	filepaths := os.ls(path) or { eprintln(err); exit(1) }.filter(os.file_ext(it) == ext)

	for _, p in filepaths {
		filepath := get_filepath_from_path(path, p)
		path_encoded := base64.url_encode_str(filepath)
		cached_files << CachedFile{filepath: get_filename(p), encoded: path_encoded}
	}

	return $veb.html('./templates/partials/results_playlist.html')
}

