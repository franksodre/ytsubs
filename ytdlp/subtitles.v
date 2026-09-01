module ytdlp

import json2 as j2
import entity

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
pub fn download(url string, path ?string) ! {
	result := download_cmd(url, path)
	if result.exit_code != 0 {
		eprintln(result.exit_code)
		eprintln(parse_output_result(result.output))
		return error('')
	}
	return
}

// @return !string
fn parse_output_result(output string) []string {
	lines := output.split_into_lines()
	return lines
	/*@todo*/
}
