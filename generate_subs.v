module main

import veb
import os
import strings
import rand

import config
import ytdlp

fn render_one_sub(path string, lst []ytdlp.Metadata) string {
	mut sb := strings.new_builder(50)

	file_path := os.glob(path + '*.vtt') or {
		eprintln(err)
		return 'Nothing to render'
	}
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

	files := os.glob(path + '*.vtt') or {
		eprintln(err)
		return 'Nothing to render'
	}
	println("path: ${path}")

	if files.len == 0 {
		return "No subs available"
	}

	for _, f in files {
		base := os.base(f)
		sb.write_string('<div>')
			sb.write_string(view_html_download(base, base))
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
		return ctx.request_error('field URL cannot be empty. Please enter a valid YT URL')
	}

	// n_entries, playlist_id and id are the same in subs and metadata That doesn't change at all - TODO something to optimize it.
	data := ytdlp.new_data(url)
	metadata := data.get_sub_metadata() or { return ctx.html("<div id='error'>Error1<div>") }
	n_entries := metadata[0].n_entries


	if n_entries > 1 {
		mut cached_path := app.lookup().get_path(metadata[0].playlist_id) or {eprintln(err); exit(1)}
		// If is cached
		if cached_path != '' {
			return ctx.html(render_playlist(cached_path, []ytdlp.Metadata{}))
		}

		subs, _ := metadata.generate(fpath) or { return ctx.html("<div id='error'>Error2<div>") }
		app.lookup().add_path(metadata[0].playlist_id, path) or {eprintln("Faild to cache item"); exit(1)}

		return ctx.html(render_playlist(path, subs))

	} else {
		// TODO(franksodre):Refactor. The only difference is that one uses id and the other uses playlist_id!
		mut cached_path := app.lookup().get_path(metadata[0].id) or {eprintln(err); exit(1)}

		if cached_path != '' {
			return ctx.html(render_one_sub(cached_path, []ytdlp.Metadata{}))
		}
		subs, _ := metadata.generate(fpath) or { return ctx.html("<div id='error'>Error2<div>") }
		app.lookup().add_path(metadata[0].id, path) or {eprintln("Faild to cache item"); exit(1)}

		return ctx.html(render_one_sub(path, subs))
	}

	// TODO(franksodre): I should have only one function and check if is a playlist in there.
	// TODO(franksodre): n_entries should be in data.
}


