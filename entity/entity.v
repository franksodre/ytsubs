module entity

pub struct Info {
pub:
	videoid   string
	title     string
	duration  string
	url       string
	language  string
}

pub struct InfoPlaylist {
pub:
	playlist_id    string
	playlist_title string
	video_info     []Info
}

// SubtitleCache contains application state about a downloaded subtitle.
// It deliberately does not belong to Info: path and format describe our
// cached artifact, not the YouTube video itself.
pub struct SubtitleCache {
pub:
	id        int
	video_id  string
	format    string
	path      string
}

pub struct PlaylistSubtitleCache {
pub:
	id          int
	playlist_id string
	format      string
	path        string
}
