module repo

import entity { PlaylistSubtitleCache, SubtitleCache }

pub struct UseCase {
pub:
	cache Repository
}

pub fn (u UseCase) find_video(video_id string, format string) ?SubtitleCache {
	return u.cache.lookup_video(video_id, format)
}

pub fn (u UseCase) find_playlist(playlist_id string, format string) ?PlaylistSubtitleCache {
	return u.cache.lookup_playlist(playlist_id, format)
}

pub fn (u UseCase) save_video(item SubtitleCache) ! {
	return u.cache.save_video(item)
}

pub fn (u UseCase) save_playlist(item PlaylistSubtitleCache) ! {
	return u.cache.save_playlist(item)
}
