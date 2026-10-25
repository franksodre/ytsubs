// vfmt off
module render
import entity
import ytdlp

interface Render {
	render() string
}

pub struct VideoRender {
pub:
	info 				entity.Info
	filepath 		string
	file_format string
	// for now let them in here
	encoded 		string
	errors			[]ytdlp.ParserError
} 

pub struct PlaylistRender {
pub:
	info 				entity.InfoPlaylist
	filepath 		string
	file_format string
	// for now let them in here
	encoded 		string
	errors			[]ytdlp.ParserError
} 

pub fn (r VideoRender) render() string {
	rendering := 'rendering'
	return 'video rendering...'
}

pub fn (r PlaylistRender) render() string {
	return 'playlist rendering...'
}

pub fn display_error(err IError) string {
	return '<div id="error" class="text-red-400 font-semibold">${err.msg()}</div>'
}

pub fn display_error_string(err string) string {
	return '<div id="error" class="text-red-400 font-semibold">${err}</div>'
}

pub fn display_warn(err IError) string {
	return "<div class='text-amber-500 font-medium'><span class='bg-amber-300
	text-white font-bold px-2 rounded mr-2'>!</span>${err.msg()}</div>"
}

pub fn display_warn_string(err string) string {
	return "<div class='text-amber-500 font-medium'><span class='bg-amber-300
	text-white font-bold px-2 rounded mr-2'>!</span>${err}</div>"
}
