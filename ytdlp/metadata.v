module ytdlp

import json2
pub struct Metadata {
pub:
	id					string
	title 			string
	url 				string @[json: 'original_url']
	n_entries 	string @[omitempty]
}

pub fn get_sub_metadata(url string) ![]Metadata {
	return decode_metadata(yt_get_metadata(url))
}

// returns succeeded generated subs metadata and failed ones
pub fn (m []Metadata) generate() !([]Metadata, []Metadata) {
	f := m.filter(ytdlp.yt_generate_sub(it.url).exit_code != 0)
	data := diff_meta(m, f) // TODO(franksodrelima): test this
	return data, f
}

fn decode_metadata(d string) ![]Metadata {
	data := '[${d.all_before_last(",")}]'
	meta := json2.decode[[]Metadata](data)!
	return meta
}
