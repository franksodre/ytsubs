module entity

pub struct Info {
pub:
	videoid   string @[json: 'id']
	title     string
	duration  string
	url       string
	language  string
}

pub struct InfoPlaylist {
pub:
	// remove `playlist` prefixes
	playlist_id    string 
	playlist_title string
	playlist_url	 string
	video_info     []Info @[json: 'video']
}

// SubtitleCache is the persisted representation of a downloadable video.
// Download-specific state stays here instead of leaking into Info.
@[table: 'SubtitleCache']
pub struct SubtitleCache {
pub:
	id        			int @[primary; sql: serial]
	video_id  			string
	title     			string
	duration  			string
	url       			string
	language  			string
	format    			string
	path      			string
}

@[table: 'PlaylistSubtitleCache']
pub struct PlaylistSubtitleCache {
pub:
	id          int @[primary; sql: serial]
	playlist_id string
	format      string
	path        string
}
