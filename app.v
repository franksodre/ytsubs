module main
import veb
import db.sqlite
import repo
import entity
import ytdlp.urlparser

pub struct App {
	veb.StaticHandler
pub mut:
	db 	sqlite.DB
}

pub struct Context {
	veb.Context
pub mut:
	title 	string
	data		entity.Info
	url			urlparser.URL
}


fn (app &App) cache() repo.UseCase {
	return repo.UseCase{
		cache: repo.new_repo(app.db)
	}
}
