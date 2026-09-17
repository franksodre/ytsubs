module entity

@[json: 'Info']
pub struct Info {
pub:
	videoid   string @[json: 'id']
	title     string
	duration  string
	url       string
	language  string
}

@[json: 'InfoPlaylist']
pub struct InfoPlaylist {
pub:
	playlist_id    string // this is not being used anywhere
	playlist_title string
	video_info     []Info
}

@[table: 'SubtitleCache']
pub struct SubtitleCache {
pub:
	id				int @[primary; sql: serial]
	videoid   string @[json: 'id']
	title     string
	duration  string
	url       string
	language  string
	path      string
	format		string
}

@[table: 'PlaylistSubtitleCache']
pub struct PlaylistSubtitleCache {
pub:
	id           int @[primary; sql: serial]
	playlist_id	 string
	path         string
	video_format string
}
