module repo

import orm
import entity { SubtitleCache, PlaylistSubtitleCache }

struct Repository {
	db 	orm.Connection
}

// be careful with the .fisrt() calls

pub fn new_repo(db orm.Connection) Repository {
	return Repository{db: db}
}

pub fn migrate(db orm.Connection) ! {
	sql db {
		create table Info
		create table InfoPlaylist
	}!
}

// fn (r Repository) lookup[T] (code string, format string, query fn (orm.Connection, string, string) T) T {
// 	return query(r.db, code, format)
// }

// fn (r Repository) add_key[T] (item T, query fn (orm.Connection, T) !) ! {
// 	return query(r.db, item)
// }

// This can't return an array
// @known calling first might panic cause the info can be empty
(r Repository) fn find(id string, sub_format string) ?SubtitleCache {
	item := sql r.db {
		select from SubtitleCache where videoid == id && format == sub_format
		order by id desc limit 1
	} or { none }
	return item[0] or { none }
}

// This can't return an array
// @known calling first might panic cause the info can be empty
fn (r Repository) find_playlist(id string, sub_format string) ?PlaylistSubtitleCache {
	item := sql r.db {
		select from PlaylistSubtitleCache where playlist_id == id && video_format == sub_format
		order by id desc limit 1
	} or { none }
	return item[0] or { none }
}

(r Repository) fn save(item SubtitleCache) ! {
	sql r.db {
		insert item into SubtitleCache
	}!
}

(r Repository) fn save_playlist(item PlaylistSubtitleCache) ! {
	sql r.db {
		insert item into PlaylistSubtitleCache
	}!
}
