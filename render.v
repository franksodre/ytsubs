module main

import os
import encoding.base64
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

	println(info)
	// TODO(franksodre): make the file format dynamic [vtt, srt, ass]
	filepath := os.glob('${info.path}*.${info.format}') or {
		eprintln(err)
		return "There are no subs for this video."
	}

	if filepath.len == 0 {
		println(filepath)
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

	println(info_playlist)
	if info_playlist.video_info.len == 0 {
		return "This playlist is empty."
	}
	// TODO(franksodre): make the file format dynamic [vtt, srt, ass]
	filepaths := os.glob('${info_playlist.path}*.vtt') or {
		eprintln(err)
		return "There are no subs for this video."
	}
	if filepaths.len == 0 {
		return "There are no subs for this video."
	}

	for k, path in filepaths {
		// yeah, still don't love it.
		title := get_filename(path)
		encoded := base64.url_encode_str(os.file_name(path))
		base_dir := os.dir(path).split('/').last()
		video_url := info_playlist.video_info[k].url

		s += '<div><a href="download/sub?d=${base_dir}&name=${encoded}"
		download="${os.file_name(path)} "class="font-medium hover:underline">${title}</a></div>'
		s += '<div class="bg-red-600 rounded w-fit p-2 mt-2"><a
		href="${video_url}" class="font-bold text-white"
		target="_blank">Youtube</a></div><br>'
	}
	return s
}

// TODO(franksodre): remove reverse calls
// returns the filename without it's extension
fn get_filename(filename string) string {
	mut count := 0
	mut s := ""
	title := os.file_name(filename)
	for k, c in title.reverse() {
		if c == `.` {
			count++
			if count == 2 {
				s = title.reverse()[k..]
				break;
			}
		}
	}
	return s.reverse()
}
