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

fn (app &App) lookup() repo.UseCase {
	return repo.UseCase{
		lookup: repo.lookup(app.db)
	}
}

fn main() {
	mut db := sqlite.connect('./migration/lookup.db')!
	defer { db.close() or {} }
	repo.migrate(db)!
	mut app := &App{ db: db }
	veb.run[App, Context](mut app, config.port)
}
