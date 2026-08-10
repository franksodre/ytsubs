module repo

import db.sqlite
import orm

// Entity
pub struct Lookup {
	code 	string @[primary; unique]
	path 	string
}

// Connection
pub struct LookupRepo {
	db	orm.Connection
}

pub fn migrate(db orm.Connection) ! { 
	sql db {
		create table Lookup
	}!
}

pub fn lookup(db orm.Connection) LookupRepo { 
	return LookupRepo{
		db: db
	}
}

pub fn (l LookupRepo) add_key(lookup Lookup) ! {
	sql l.db {
		insert lookup into Lookup
	} or { return err }
}

pub fn (l LookupRepo) set_key(code string, val string) ! { 
	sql l.db {
		update Lookup set code = val where code == code
	} or { return err }
}

pub fn (l LookupRepo) get_table_by_code(code string) ![]Lookup {
	lk := sql l.db {
		select path from Lookup where code == code
	} or { return err }
	return lk // it should be unique btw, so check for that in useCases
}

pub fn (l LookupRepo) lookup(code string) ![]Lookup {
	lk := sql l.db {
		select from Lookup where code == code
	} or { return err }
	return lk
}
