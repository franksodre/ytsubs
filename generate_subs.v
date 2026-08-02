module main

import veb
import os
import config
import ytdlp
import strings
import rand

fn render_one_sub(path string, lst []ytdlp.Metadata) string {
	mut sb := strings.new_builder(50)

	file_path := os.glob(path + '*.vtt') or {
		eprintln(err)
		return 'Nothing to render'
	}
	println(file_path)
	if file_path != [] {
		sb.write_string('<div>')
		// Give the correct path for correct download
		sb.write_string(view_html_download(os.base(file_path[0]), lst.first().title))
		sb.write_string('</div><br><br>')
		return sb.str()
	}
	return 'No subs available'
}

fn render_playlist(path string, list []ytdlp.Metadata) string {
	mut sb := strings.new_builder(50)

	for k, _ in list {
		file_path := os.glob(path + '*.vtt') or {
			eprintln(err)
			return 'Nothing to render'
		}
		// # if file_path == [] { TODO(franksodre) }
		sb.write_string('<div>')
		sb.write_string(view_html_download(os.base(file_path[k]), os.base(file_path[k])))
		sb.write_string('</div><br><br>')
	}
	return sb.str()
}

@['/'; get]
fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/index.html'))
}

@['/'; post]
fn (app &App) post(mut ctx Context) veb.Result {
	uuid := rand.uuid_v4()
	fpath := os.join_path(os.getwd(), 'save', uuid + '/%(title)s.%(ext)s') // formatted path
	path := os.join_path(os.getwd(), 'save', uuid + '/')
	url := ctx.form['url'] or {
		return ctx.request_error('The url field cannot be empty. Please try to enter an url (you can copy a youtube link)')
	}

	data := ytdlp.new_data(url)
	metadata := data.get_sub_metadata() or { return ctx.html("<div id='error'>Error1<div>") }
	// I cannot depend in generate to create the path 'cause is too unpredictable or just have more control of it.
	// I'm assuming that the downloads always succeeds which is dumb cause it's like that.
	// but if I handle that I also need to handle the creating dir phase.
	// That's why it should be separated.
	// I shouldn't assume it will just work instead I should be doing the right opposite.
	subs, _ := metadata.generate(fpath) or { return ctx.html("<div id='error'>Error2<div>") }

	// TODO(franksodre): I should have only one function and check if is a playlist in there.
	if subs[0].n_entries > 1 {
		return ctx.html(render_playlist(path, subs))
	} else {
		return ctx.html(render_one_sub(path, subs))
	}
}
