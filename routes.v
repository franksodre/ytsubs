module main

import veb
import os
import config

import net.urllib
import ytdlp

import strings
import arrays
import json

@['/'; get]
fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/index.html'))
}

@['/'; post]
fn (app &App) post(mut ctx Context) veb.Result {
	url := ctx.form['url'] or { '' }
	metadata := '[' + ytdlp.get_video_metadata(url).all_before_last(',') + ']'
	mut sb := strings.new_builder(100)

	subs := handle_video(metadata)
	mut failed := []Subtitle{}

	for sub in subs {
		subsub := ytdlp.create_sub(sub.original_url)
		if subsub.exit_code != 0 {
			failed << sub
		}
	}
	generated_subs := diff_sub(subs, failed) 
	entries := os.ls(config.save_dir) or { [] }
	// I don't like it either!
	sb.write_string('<div>')
	for k, entry in entries {
		sb.write_string(view_html_download(entry, generated_subs[k].title))
	}
	sb.write_string('</div><br>')
	
	sb.write_string('<div>')
	for _, fail in failed {
		sb.write_string('<h1>FAILED:</h1>')
		sb.write_string('<a href="${fail.original_url}">${fail.title}</a>')
	}
	sb.write_string('</div>')
	return ctx.html(sb.str())
}

// /subs/:id
@['/subs/:filename'; get]
fn (app &App) download(mut ctx Context, filename string) veb.Result {
		file := config.save_dir + filename
		ctx.set_content_type("text/vtt")
		return ctx.file(file)
}
