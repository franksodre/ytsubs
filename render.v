module main

import os
import strings
import entity { Info, InfoPlaylist }
import context {
	todo 
	cause
}

pub type InfoRender = Info | InfoPlaylist

pub struct Render{}
/*


r := new_render()
r.display()

*/

pub fn new_render() /*Render */ {}
pub fn (r Render) display[T](info InfoRender) /*T*/ {
	$if info is Info {/*render_sub_info*/ }
	$if info is InfoPlaylist { /*render_sub_info_playlist*/}
}

fn render_sub_info() {}
fn render_sub_info_playlist() {}

fn render_one_sub(info Info) string {
	mut sb := strings.new_builder(50)

	if info.path == '' {
		return 'No subs available'
	}

	file_path := os.glob(info.path + '*.vtt') or {
		eprintln(err)
		return 'Nothing to render'
	}
	if file_path != [] {
		sb.write_string('<div>')
		path := info.path.split('/').reverse()[1]
		filename := os.file_name(file_path[0])
		sb.write_string(view_html_download(path, filename, filename))
		sb.write_string('</div><br><br>')
		return sb.str()
	}
	return 'No subs available'
}

fn render_playlist(info_playlist InfoPlaylist) string {
	mut sb := strings.new_builder(50)

	files := os.glob(info_playlist.path + '*.vtt') or {
		eprintln(err)
		return 'Nothing to render'
	}
	if files.len == 0 {
		return "No subs available"
	}

	for _, f in files {
		path := info_playlist.path.split('/')[info_playlist.path.len - 2]
		filename := os.file_name(f)
		sb.write_string('<div>')
		sb.write_string(view_html_download(path,filename, filename))
		sb.write_string('</div><br><br>')
	}

	return sb.str()
}
