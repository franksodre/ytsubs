module main

import encoding.base64
import entity { Info, InfoPlaylist }
import os
import time

pub struct Render {}

pub fn new_render() Render {
	return Render{}
}

pub fn (r Render) display[T](item T) string {
	$if T is Info {
		return render_sub_info(item)
	} $else {
		return render_sub_info_playlist(item)
	}
}

fn render_sub_info(info Info) string {
	if info.path == '' {
		return "There are no subs for this video."
	}

	pattern := '.' + info.format
	filepath := os.ls(info.path) or {
		eprintln(err)
		return "There are no subs for this video."
	}.filter(os.file_ext(it) == pattern)

	if filepath.len == 0 {
		return "There are no subs for this video."
	}

	// still don't like it.
	title := get_filename(filepath[0])
	filename := os.file_name(filepath[0])
	base_dir := os.dir(filepath[0]).split('/').last()
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

fn render_sub_info_playlist(info_playlist InfoPlaylist) string {
	mut s := ""
	if info_playlist.path == '' {
		return "Unable to process playlist."
	}
	if info_playlist.video_info.len == 0 {
		return "This playlist is empty."
	}

	// The filtering is almost always unnecessary.
	// The dir will always have the spected format.

	pattern := '.' + info_playlist.video_format
	filepaths := os.ls(info_playlist.path) or {
		eprintln(err)
		return "There are no subs for this video."
	}.filter(os.file_ext(it) == '.' + info_playlist.video_format)

	if filepaths.len == 0 {
		return "There are no subs for this video."
	}

	for k, path in filepaths {
		// yeah, still don't love it.
		title := get_filename(path)
		base_dir := os.dir(path).split('/').last()
		url := info_playlist.video_info[k].url
		encoded := base64.url_encode_str(os.file_name(path))

		s += '<div><a href="download/sub?d=${base_dir}&name=${encoded}"
		download="${os.file_name(path)} "class="font-medium hover:underline">${title}</a></div>'
		s += '<div class="bg-red-600 rounded w-fit p-2 mt-2"><a
		href="${url}" class="font-bold text-white"
		target="_blank">Youtube</a></div><br>'
	}
	return s
}

fn (r Render) display_error(err IError) string {
	return '<div id="error" class="text-red-400 font-semibold">${err.msg()}</div>'
}

fn (r Render) display_error_string(err string) string {
	return '<div id="error" class="text-red-400 font-semibold">${err}</div>'
}

fn (r Render) display_warn(err IError) string {
	return "<div class='text-amber-500 font-medium'><span class='bg-amber-300
	text-white font-bold px-2 rounded mr-2'>!</span>${err.msg()}</div>"
}

fn (r Render) display_warn_string(err string) string {
	return "<div class='text-amber-500 font-medium'><span class='bg-amber-300
	text-white font-bold px-2 rounded mr-2'>!</span>${err}</div>"
}
