module repo
import os

pub struct UseCase {
pub:
	lookup	ILookupRepo @[required]
}

pub interface ILookupRepo {
	lookup(code string) ![]Lookup
	add_key(Lookup) !
}

// The code is the youtube id
pub fn (u UseCase) get_path(code string) !string {
	lk := u.lookup.lookup(code)!
	if lk.len != 0 {
		return lk.first().path
	}
	return ''
}

pub fn (u UseCase) add_path(code string, path string) ! {
	lk := u.lookup.lookup(code)!
	if lk.len != 0 {
		return
	}

	u.lookup.add_key(Lookup{code: code, path: path})!
	return
}

// if !os.exists(path) {
// 	eprintln("Path doesn't exists, path: ${path}")
// 	return error()
// }
//
