module main

import veb
import config
import db.sqlite
import repo


@['/']
fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.html($tmpl('./templates/index.html'))
}

fn main() {
	mut db := sqlite.connect(config.db_url)!
	defer { db.close() or {} }

	repo.migrate(db)!

	mut app := &App{ db: db }
	veb.run[App, Context](mut app, config.port)
}
