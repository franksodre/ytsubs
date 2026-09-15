module main

import encoding.base64
import entity { Info, PlaylistSubtitleCache, SubtitleCache }
import os

pub struct Render {}

pub fn new_render() Render {
	return Render{}
}

pub fn (r Render) display(info Info, cache SubtitleCache) string {
	if cache.path == '' {
		return "There are no subs for this video."
	}

	filepath := subtitle_files(cache.path, cache.format)
	if filepath.len == 0 {
		return "There are no subs for this video."
	}

	path := filepath[0]
	title := get_filename(path)
	filename := os.file_name(path)
	base_dir := os.dir(path).split('/').last()
	encoded := base64.url_encode_str(filename)
	return '
		<div><a href="download/sub?d=${base_dir}&name=${encoded}"
		download="${filename}" class="text-semibold hover:underline">${title}</a></div>
		<div class="bg-red-600 rounded w-fit p-2 mt-2"><a
			href="${info.url}" class="font-bold text-white"
			target="_blank">Youtube</a></div><br>
		<br><br>
		'
}

pub fn (r Render) display_playlist(info InfoPlaylist, cache PlaylistSubtitleCache) string {
	if cache.path == '' {
		return "Unable to process playlist."
	}
	if info.video_info.len == 0 {
		return "This playlist is empty."
	}

	filepaths := subtitle_files(cache.path, cache.format)
	if filepaths.len == 0 {
		return "There are no subs for this video."
	}

	mut s := ""
	for k, path in filepaths {
		// Do not sort this list. yt-dlp writes files in playlist order and the
		// metadata list uses the same order. Sorting by filename can break the
		// association when titles differ from that order.
		if k >= info.video_info.len {
			break
		}
		title := get_filename(path)
		base_dir := os.dir(path).split('/').last()
		url := info.video_info[k].url
		encoded := base64.url_encode_str(os.file_name(path))

		s += '<div><a href="download/sub?d=${base_dir}&name=${encoded}" download="${os.file_name(path)}" class="font-medium hover:underline">${title}</a></div>'
		s += '<div class="bg-red-600 rounded w-fit p-2 mt-2"><a href="${url}" class="font-bold text-white" target="_blank">Youtube</a></div><br>'
	}
	return s
}

fn subtitle_files(path string, format string) []string {
	pattern := '.' + format
	return os.ls(path) or { [] }.filter(os.file_ext(it) == pattern)
}

fn (r Render) display_error(err IError) string {
	return '<div id="error" class="text-red-400 font-semibold">${err.msg()}</div>'
}

fn (r Render) display_error_string(err string) string {
	return '<div id="error" class="text-red-400 font-semibold">${err}</div>'
}

fn (r Render) display_warn(err IError) string {
	return "<div class='text-amber-500 font-medium'><span class='bg-amber-300 text-white font-bold px-2 rounded mr-2'>!</span>${err.msg()}</div>"
}

fn (r Render) display_warn_string(err string) string {
	return "<div class='text-amber-500 font-medium'><span class='bg-amber-300 text-white font-bold px-2 rounded mr-2'>!</span>${err}</div>"
}
