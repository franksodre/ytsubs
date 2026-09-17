module repo
import entity { SubtitleCache, PlaylistSubtitleCache }

pub struct UseCase {
pub:
	cache Repository
}

// The code is the youtube id
pub fn (u UseCase) find_video(video_id string, format string) ?SubtitleCache {
	return u.cache.find_video(video_id, format)
}

pub fn (u UseCase) find_playlist(video_id string, format string) ?PlaylistSubtitleCache {
	return u.cache.find_playlist(video_id, format)
}

pub fn (u UseCase) save_video(item SubtitleCache) ! {
	return u.cache.save_video(item)
}

pub fn (u UseCase) save_playlist(item PlaylistSubtitleCache) ! {
	return u.cache.save_playlist(item)
}
