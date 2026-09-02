module main

import os
import entity { Info, InfoPlaylist }
pub struct Render{}

pub fn new_render() Render {return Render{}}
pub fn (r Render) display[T](item T) string {
	$if T is Info {
		return render_sub_info(item) 
	} $else { return render_sub_info_playlist(item) }
}

fn render_sub_info(info Info) string {
	if info.path == '' {
		return "There are no subs for this video."
	}
	// @known the format should be dynamic
	filepath := os.glob('${info.path}*.vtt') or {
		eprintln(err)
		return "There are no subs for this video."
	}
	// should check bounds?
	if filepath.len == 0 {
		return "There are no subs for this video."
	}

	dir, filename, ext := os.split_path(filepath[0])
	return '
		<div><a href="download/sub?d=${dir.split('/').last()}&name=${filename + ext}"
		download="${filename}" class="text-semibold hover:underline">${filename.all_before_last('.')}</a></div>
		<br><br>
		'
}

fn render_sub_info_playlist(info_playlist InfoPlaylist) string {
	mut s := ""
	if info_playlist.path == '' {
		return "There are no subs for this video."
	}
	// @known the format should be dynamic
	filepaths := os.glob('${info_playlist.path}*.vtt') or {
		eprintln(err)
		return "There are no subs for this video."
	}
	if filepaths.len == 0 {
		return "There are no subs for this video."
	}

	for _, path in filepaths {
		dir, filename, ext := os.split_path(path)
		s += '<div><a href="download/sub?d=${dir.split('/').last()}&name=${filename+ ext}"
		download="${filename} "class="text-semibold hover:underline">${filename.all_before_last('.')}</a></div>
		<br><br> '
	}
	return s
}
