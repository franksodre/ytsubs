module main

import veb
import config

@[noinit]
pub struct App {
	veb.StaticHandler
}

pub struct Context {
	veb.Context
pub mut:
	title 	string
}

fn main() {
	mut app := &App{}
	veb.run[App, Context](mut app, config.port)
}
