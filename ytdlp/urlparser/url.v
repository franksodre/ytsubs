module urlparser

import net.urllib

/// All of this might not be that accurate, I didn't search youtube's url format yet. !important

// TODO(franksodre): Check for id length !important

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
pub fn (url URL) is_playlist() bool {
	if url.query['list'].len <= 0 {
		return false
	}
	return true
}

pub fn (url URL) get_video_id() !string {
	// what if both
	if !url.parsed.path.contains('watch') && !url.parsed.path.contains('shorts') {
		return error('Invalid Youtube URL format or incomplete.')
	}
	
	// @seelater
	id := if url.parsed.path.contains('shorts') {
		url.parsed.path[1..].split('/')[1] or { '' } // this might fail if path.len == 1
	} else {
		url.query['v'][0] or { '' }
	}
	if id == '' {
		return error('No video id was found.')
	} 
	println(id)

	return id
}

pub fn (url URL) get_playlist_id() !string {
	if !url.is_playlist() {
		return error('Unable to get playlist id. Not a playlist.')
	}
	id := url.query['list']
	if id.len == 0 {
		return error('No playlist id was found.')
	}
	if id.len > 1 {
		return error('Multiple ids outside a playlist is not supported')
	}
	return id[0]
}

pub fn (url URL) get_id() !string {
	if !url.is_playlist() {
		println('[URL]: Getting video id.')
		return url.get_video_id()!
	}
	println('[URL]: Getting playlist id.')
	return url.get_playlist_id()!
}

// @unimplemented
fn is_valid_url() {}
