module ytdlp

import json2 as j2
import entity

pub enum ErrorType {
	some_failed
	all_failed
	succeeded
	no_subs_available
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
pub fn download(params DownloadParams) ([]ErrorType, []string) {
	result := download_cmd(params)
	if result.exit_code != 0 {
		return parse_output_result(result.output)
	}
	// for no_subs_available case -- There has to be a better way
	println(parse_output_result(result.output))
	return []ErrorType{}, []string{}
}

// if we have [download] Destination
// if we have [info] Writing video subtitles to:
// if we have ERROR: [youtube] _id_:

// @known Maybe return all the states too
fn parse_output_result(output string) ([]ErrorType, []string) {
	lines := output.split_into_lines()
	mut msg := []string{}
	mut states := []ErrorType{}
	for line in lines {
		if line.starts_with('[info] There are no subtitles for the requested languages') {
			// video_id := lines[i-1].all_before(':').all_after(' ')
			states << .no_subs_available
			msg << 'There are no subtitles for the requested languages'
			continue
		}
		if line.starts_with('[download] Destination:') {
			states << .succeeded
			continue
		}
		if line.starts_with('[info]: Writing video subtitles to:') {
			states << .succeeded
			continue
		}
		// if the same error repeats count it and show it alongside with the count
		if line.starts_with('ERROR: [youtube]') {
			msg << line.all_after_last(':')
			// @known not simple as that. At this point we better create a really simple states machine.
			if ErrorType.succeeded in states {
				states << .some_failed
				continue
			}
			states << .all_failed
		}
	}
	return states, msg
}
