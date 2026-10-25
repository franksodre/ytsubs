module main

import rand
import os

fn create_save_dir() string {
	uuid := rand.uuid_v4()
	path := os.join_path(os.getwd(), 'save', uuid + '/')
	return path
}

// TODO(franksodre): remove reverse calls
// returns the filename without it's extension
fn get_filename(filename string) string {
	mut count := 0
	mut s := ""
	title := os.file_name(filename)
	for k, c in title.reverse() {
		if c == `.` {
			count++
			if count == 2 {
				s = title.reverse()[k..]
				break;
			}
		}
	}
	return s.reverse()
}

// path should probably be renamed to filename or something but it's 3:36 and I'm tired.
fn get_filepath_from_path(path string, filename string) string {
	base_dir := os.dir(path).split('/').last()
	filepath := os.join_path_single(base_dir, filename)
	return filepath
}
