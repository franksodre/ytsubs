module main

import rand
import os

fn create_save_dir() string {
	uuid := rand.uuid_v4()
	path := os.join_path(os.getwd(), 'save', uuid + '/')
	return path
}

// @tmp
// fn view_html_download(dir string, filename string, value string) string {
// 	return '<a href="download/sub?d=${dir}&name=${filename}" download class="text-semibold hover:underline">${value}</a>'
// }
