module repo

import orm
import entity {Info, InfoPlaylist}

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

fn (r Repository) lookup[T] (code string, format string, query fn (orm.Connection, string, string) T) T {
	return query(r.db, code, format)
}

fn (r Repository) add_key[T] (item T, query fn (orm.Connection, T) !) ! {
	return query(r.db, item)
}

// This can't return an array
// @known calling first might panic cause the info can be empty 
fn lookup_info(db orm.Connection, id string, sub_format string) Info {
	info := sql db {
		select from Info where videoid == id && format == sub_format
		order by id desc limit 1
	} or { [] }
	return info[0] or { Info{} }
}

// This can't return an array
// @known calling first might panic cause the info can be empty 
fn lookup_info_playlist(db orm.Connection, id string, sub_format string) InfoPlaylist {
	info := sql db {
		select from InfoPlaylist where playlist_id == id && video_format == sub_format
		order by id desc limit 1
	} or { [] }
	return info[0] or { InfoPlaylist{} }
}

fn add_key_info(db orm.Connection, item Info) ! {
	sql db {
		insert item into Info
	}!
}

fn add_key_playlist(db orm.Connection, item InfoPlaylist) ! {
	sql db {
		insert item into InfoPlaylist
	}!
}
