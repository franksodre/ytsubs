// why is this for again?
module ytdlp

import json2

// TODO(franksodre): Data not Metadata

pub struct Metadata {  
pub:
	id					string
	title 			string
	url 				string @[json: 'original_url']
	n_entries 	int @[omitempty] // This is just because I'm not yet decoding Data.
	playlist_id string
}

pub struct Data {
pub: 
	url  			string @[required]
	metadata 	[]Metadata
}

pub fn new_data(url string) Data {
	return Data{ url: url }
}

pub fn (d Data) get_sub_metadata() ![]Metadata {
	return decode_metadata(yt_get_metadata(d.url)) or {eprintln(err); exit(1)}
}

// returns succeeded generated subs metadata and failed ones
pub fn (m []Metadata) generate(path ?string) !([]Metadata, []Metadata) {
	// This is slower than calling the [playlist mode] directly.
	f := m.filter(ytdlp.yt_generate_sub(it.url, path).exit_code != 0) // I should unwrap it in here
	data := diff_meta(m, f) // TODO(franksodrelima): test this
	return data, f
}

fn decode_metadata(metadata string) ![]Metadata {
	data := '[${metadata.all_before_last(",")}]'
	decoded_meta := json2.decode[[]Metadata](data)!
	return decoded_meta
}

// not so trusthy
// I'm not even putting data in metdata. What a dumbass.
// pub fn (d Data) is_playlist() bool {
// 	return d.metadata[0].n_entries > 1
// }
