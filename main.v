module main

import veb
import config
import db.sqlite
import repo

pub struct App {
	veb.StaticHandler
pub mut:
	db 	sqlite.DB
}

pub struct Context {
	veb.Context
pub mut:
	title 	string
}

fn (app &App) cache() repo.UseCase {
	return repo.UseCase{
		cache: repo.new_repo(app.db)
	}
}

@['/'; get]
fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/index.html'))
}

fn main() {
	mut db := sqlite.connect('./migration/lookup.db')!
	defer { db.close() or {} }
	repo.migrate(db)!
	mut app := &App{ db: db }
	veb.run[App, Context](mut app, config.port)
}
