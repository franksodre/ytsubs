module ytdlp
import os

// @notice: Not sure it should use globs or the filename
// if the filename is used the from should removed

// This function can be _from_to or just _to
/// The filename cannnot contain an extension
fn convert_sub_from_to(filename string, to string) string {
	ext := os.file_ext(filename)
	cmd := 'ffmpeg -i *.${ext} ${filename}.${to}'
	return cmd
}

@[inline]
pub fn convert_to_ass(filename string) {
	cmd := convert_sub_from_to(filename, "ass")
	os.execute(cmd)
}

@[inline]
pub fn convert_to_vtt(filename string) {
	cmd := convert_sub_from_to(filename, "vtt")
	os.execute(cmd)
}

@[inline]
pub fn convert_to_srt(filename string) {
	cmd := convert_sub_from_to(filename, "srt")
	os.execute(cmd)
}
