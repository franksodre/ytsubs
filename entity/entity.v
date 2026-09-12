module entity

@[json: 'Info'; table: 'Info']
pub struct Info {
pub:
	id        int @[primary; sql: serial; json: '-']
	parent_id int
	videoid   string @[json: 'id']
	title     string
	duration  string
	url       string
	language  string
pub mut:
	path   string
	format string
}

@[json: 'InfoPlaylist'; table: 'InfoPlaylist']
pub struct InfoPlaylist {
pub:
	id             int @[primary; sql: serial; json: '-']
	playlist_id    string @[json: 'playlist_id']
	playlist_title string
	video_info     []Info @[fkey: 'parent_id'; json: 'video']
pub mut:
	path         string
	video_format string
}
