module database

pub struct Lookup {
	id		string @[primary]
	path 	string
}

pub fn migrate() ! { }

pub fn Lookup.new_lookup() !Lookup { }
