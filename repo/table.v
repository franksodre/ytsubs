module repo

import orm
import entity { SubtitleCache, PlaylistSubtitleCache }

struct Repository {
	db orm.Connection
}

// be careful with the .fisrt() calls

pub fn new_repo(db orm.Connection) Repository {
	return Repository{ db: db }
}

pub fn migrate(db orm.Connection) ! {
	sql db {
		create table SubtitleCache
		create table PlaylistSubtitleCache
	}!
}

// @known calling first might panic cause the info can be empty
fn (r Repository) find_video(videoid string, sub_format string) ?SubtitleCache {
	item := sql r.db {
		select from SubtitleCache where video_id == videoid && format == sub_format
		order by id desc limit 1
	} or { return none }
	return item[0] or { return none }
}

// This can't return an array
// @known calling first might panic cause the info can be empty
fn (r Repository) find_playlist(videoid string, sub_format string) ?PlaylistSubtitleCache {
	item := sql r.db {
		select from PlaylistSubtitleCache where playlist_id == videoid && format == sub_format
		order by id desc limit 1
	} or { return none }
	return item[0] or { return none }
}

fn (r Repository) save_video(item SubtitleCache) ! {
	sql r.db {
		insert item into SubtitleCache
	}!
}

fn (r Repository) save_playlist(item PlaylistSubtitleCache) ! {
	sql r.db {
		insert item into PlaylistSubtitleCache
	}!
}
