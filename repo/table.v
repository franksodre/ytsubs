module repo

import orm
import entity { PlaylistSubtitleCache, SubtitleCache }

struct Repository {
	db orm.Connection
}

pub fn new_repo(db orm.Connection) Repository {
	return Repository{db: db}
}

pub fn migrate(db orm.Connection) ! {
	sql db {
		create table SubtitleCache
		create table PlaylistSubtitleCache
	}!
}

pub fn (r Repository) lookup_video(video_id string, format string) ?SubtitleCache {
	rows := sql r.db {
		select from SubtitleCache
		where video_id == video_id && format == format
		order by id desc
		limit 1
	} or { return none }

	return rows[0] or { none }
}

pub fn (r Repository) lookup_playlist(playlist_id string, format string) ?PlaylistSubtitleCache {
	rows := sql r.db {
		select from PlaylistSubtitleCache
		where playlist_id == playlist_id && format == format
		order by id desc
		limit 1
	} or { return none }

	return rows[0] or { none }
}

pub fn (r Repository) save_video(item SubtitleCache) ! {
	sql r.db {
		insert item into SubtitleCache
	}!
}

pub fn (r Repository) save_playlist(item PlaylistSubtitleCache) ! {
	sql r.db {
		insert item into PlaylistSubtitleCache
	}!
}
