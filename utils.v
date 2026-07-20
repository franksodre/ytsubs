module main

import net.urllib
import strings
import json
import os

import ytdlp
import config
import arrays

// file_size, file_name, file_ext

@[soa]
struct Subtitle {
	id 	 					string
	title					string
	original_url 	string
	size 					u64
}

fn validate_url(url string) !urllib.URL {
	return urllib.parse(url) or { return error("error: malformed url") }
}

fn handle_video(metadata string) []Subtitle {
	subtitle := json.decode([]Subtitle, metadata) or {
		eprintln("Failed to decode json, error: ${err}")
		exit(1)
	}

	return subtitle
}

@[inline]
fn view_html_download(filepath string, content ?string) string {
	return '<a href="/subs/${filepath}" download>${content or {''}}</a>'
}

@[inline]
fn view_html_failed(content ?string) string {
	return ''
}


// I could just pass the id from b once that's the only thing being use.
// and this is a pretty niche function.
fn diff_sub(a []Subtitle, b []Subtitle) []Subtitle {
	mut m := map[string]bool{}
	for _, s in b {
		m[s.id] = true
	}

	diff := a.filter(!m[it.id])
	return diff
}
