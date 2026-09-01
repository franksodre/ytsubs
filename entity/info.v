module entity 

@[json: 'Info']
pub struct Info {  
pub:
	id				int @[primary; sql: serial; json: '-']
	parent_id int
	videoid		string  @[json: 'id']
	title			string	
	duration	string  
	url				string 	
pub mut:
	path	string
}

@[json: 'InfoPlaylist']
pub struct InfoPlaylist {  
pub:
	id							int			@[primary; sql: serial; json: '-']
	playlist_id 		string 	@[json: 'playlist_id']
	playlist_title	string
	video_info			[]Info   @[fkey: 'parent_id']
pub mut:
	path	string
}
