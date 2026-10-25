module ytdlp

import json2 as j2
import entity

pub enum ErrorType {
	all_failed
	no_subs_available
}

@[params]
pub struct ParserError {
pub:
	type 		ErrorType
	value 	string
	context string
}

// TODO(franksodre): Data not Metadata

pub fn extract_info(url string) ![]entity.Info {
	info := extract_info_cmd(url)
	infojson := j2.decode[[]entity.Info](info)!
	return infojson
}

pub fn extract_playlist_info(url string) ![]entity.InfoPlaylist {
	info := extract_info_playlist_cmd(url)
	infojson := j2.decode[[]entity.InfoPlaylist](info)!
	return infojson
}

// returns succeeded generated subs metadata and failed ones
pub fn download(params DownloadParams) []ParserError {
	result := download_cmd(params)
	// if result.exit_code != 0
	return parse_output_result(result.output)
}

// if we have [download] Destination
// if we have [info] Writing video subtitles to:
// if we have ERROR: [youtube] _id_:

// @known Maybe return all the states too
fn parse_output_result(output string) []ParserError {
	lines := output.split_into_lines()
	mut err := []ParserError{}
	mut url := ""
	for line in lines {
		if line.starts_with('[youtube:tab] Extracting URL:') ||
			line.starts_with('[youtube] Extracting URL:') {
			url = line.all_after_first(']').all_after_first(':').trim(' ')
		}
		if line.starts_with('[info] There are no subtitles for the requested languages') {
			err << ParserError{
				type: .no_subs_available, 
				value: url, 
				context: 'There are no subtitles for the requested languages'
			}
			continue
		}
		if line.starts_with('ERROR: [youtube]') {
			if err.len > 0 {
				continue
			}
			msg := line.all_after_last(':')
			err << ParserError{
				type: .all_failed
				context: msg
			}
		}
	}
	return err
}
