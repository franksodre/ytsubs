module ytdlp

import json2 as j2
import entity

pub enum ErrorType {
	some_failed
	none
}

// TODO(franksodre): Data not Metadata

pub fn extract_info(url string) ![]entity.Info {
	info := extract_info_cmd(url)!
	infojson := j2.decode[[]entity.Info](info)!
	return infojson
}

pub fn extract_playlist_info(url string) ![]entity.InfoPlaylist {
	info := extract_info_playlist_cmd(url)!
	infojson := j2.decode[[]entity.InfoPlaylist](info)!
	return infojson
}

// returns succeeded generated subs metadata and failed ones
pub fn download(url string, path ?string) (ErrorType, []string) {
	result := download_cmd(url, path)
	if result.exit_code != 0 {
		return parse_output_result(result.output)
	}
	return ErrorType.none, []string{}
}

// @return !string


// if we have [download] Destination
// if we have [info] Writing video subtitles to:
// if we have ERROR: [youtube] _id_:
fn parse_output_result(output string) (ErrorType, []string) {
	lines := output.split_into_lines()
	mut errs := []string{}
	mut err_type := ErrorType.none
	for line in lines {
		if line.starts_with('[download] Destination:') {
			continue
		}
		if line.starts_with('[info]: Writing video subtitles to:') {
			continue
		}
		if line.starts_with('ERROR: [youtube]') {
			errs << line.all_after_last(':')
			err_type = .some_failed
		}
	}
	return err_type, errs
}
