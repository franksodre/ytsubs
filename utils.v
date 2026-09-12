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
