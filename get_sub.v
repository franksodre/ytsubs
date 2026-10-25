module main

import entity { Info, SubtitleCache }
import os
import veb
import ytdlp
import ytdlp.urlparser as u

import encoding.base64


fn info_to_subtitle_cache(info Info, path string, format string) SubtitleCache {
	item := SubtitleCache {
		video_id: info.videoid
		title: info.title
		duration: info.duration
		url: info.url
		language: info.language
		format: format
		path: path
	}
	return item
}

@['/'; post]
fn (app &App) post(mut ctx Context) veb.Result {
	format := ctx.form['format']
	raw_url := ctx.form['url'] or { return ctx.request_error('Please submit a url!') }

	url := u.parse_url(raw_url) or {
		// ctx.res.set_status()
		eprintln(err)
		return ctx.request_error('URL malformed!')
	}

	// @maybe: use redirect instead
	if url.is_playlist() {
		return app.post_playlist(mut ctx)
	}

	id := url.get_video_id() or {
		eprintln(err)
		return ctx.request_error(err.msg())
	}

	// I would prefer this to be after the `find_video`
	info_json := ytdlp.extract_info(url.raw_url) or {
		// ctx.res.set_status(.internal_sever_error)
		eprintln(err)
		return ctx.server_error('Something wrong as happened, try again later!')
	}

	info := info_json.first()
	cached := app.cache().find_video(id, format) or {
		return download_sub(app, mut ctx, info, format)
	}

	if os.is_dir_empty(cached.path) {
		eprintln('on is_dir_empty::cached.path == `${cached.path}`')
		return ctx.text('Nothing to render!')
	}


	// todo: get rid of this repetition
	ext := '.' + format
	paths := os.ls(cached.path) or { eprintln(err); exit(1) }.filter(os.file_ext(it) == ext)
	filename := paths.map(it).last()

	filepath := get_filepath_from_path(cached.path, filename)
	path_encoded := base64.url_encode_str(filepath)

	cache := struct {filepath: get_filename(filename), encoded: path_encoded}
	errors := []ytdlp.ParserError{}

	// use redirects in post
	return $veb.html('./templates/partials/results.html')
}

// Don't like it but it's ok for now
fn download_sub(app &App, mut ctx Context, info Info, format string) veb.Result {
	// this could somehow fail?
	path := create_save_dir()

	errors := ytdlp.download(url: info.url, format: format, path: path)
	if errors.len == 0 {
		subtitle := info_to_subtitle_cache(info, path, format)
		app.cache().save_video(subtitle) or { panic('unimplemented') }
	}

	// todo: use UUIDs and lookup in the db instead of base64

	// This is not accurate by all means but it WORKS.
	ext := '.' + format
	paths := os.ls(path) or { eprintln(err); exit(1) }.filter(os.file_ext(it) == ext)
	filename := paths.map(it).last()

	filepath := get_filepath_from_path(path, filename)
	path_encoded := base64.url_encode_str(filepath)

	cache := struct {filepath: get_filename(filename), encoded: path_encoded}
	return $veb.html('./templates/partials/results.html')
}
