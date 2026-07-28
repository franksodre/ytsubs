// why is this for again?
module ytdlp

pub struct General {
pub: 
	url  string @[required]
pub mut: 
	is_playlist bool
}

pub fn General.new_general(url string) General {
	return General{url, is_playlist(url)}
}
