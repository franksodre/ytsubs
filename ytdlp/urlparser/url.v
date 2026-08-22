module urlparser

import net.urllib

// All of this might not be that accurate, I didn't search youtube's url format yet.

// TOOD(franksodre): unescape all the url first
// TOOD(franksodre): Do a yturl struct to hold changes in the url

pub struct URL {
pub:
	raw_url string
	parsed  urllib.URL
	query   map[string][]string
}

pub fn parse_url(raw_url string) !URL {
	url := urllib.parse(raw_url)!
	return URL{
		raw_url: raw_url.replace('\\', '')
		parsed:  url
		query:   url.query().to_map()
	}
}

// url : urllib.URL
// It invalidates this type of playlists: 
// https://www.youtube.com/watch?v=xxYJONmXE8w&list=RDxxYJONmXE8w&start_radio=1&rv=xxYJONmXE8w
// TODO()
pub fn (url URL) is_playlist() bool {
	if !url.parsed.path.contains('playlist') || url.query['list'].len <= 0 {
		return false
	}
	return true
}

// TODO(franksodre): Check for id length
pub fn (url URL) get_video_id() !string {
	if !url.parsed.path.contains('watch') {
		// invalid URL
		return error('Invalid Youtube URL format or incomplete.')
	}
	id := url.query['v']
	if id.len == 1 {
		return id[0]
	} 
	// invalid URL
	return error('No video id was found.')
}

// TODO(franksodre): Check for id length
pub fn (url URL) get_playlist_id() !string {
	if !url.is_playlist() {
		// invalid URL
		return error('Unable to get playlist id. Not a playlist.')
	}
	id := url.query['list']
	if id.len == 0 {
		// invalid URL
		return error('No playlist id was found.')
	}
	if id.len > 1 {
		// invalid URL
		return error('Multiple ids outside a playlist is not supported')
	}
	return id[0]
}

// Returns the id whether is a playlist or video but not both
pub fn (url URL) get_id() !string {
	if !url.is_playlist() {
		println('[URL]: Getting video id.')
		return url.get_video_id()!
	}
	println('[URL]: Getting playlist id.')
	return url.get_playlist_id()!
}

fn is_valid_url() {}
