module ytdlp

const mock_json = '{"id":"123","title":"Test"},{"id":"456","title":"Example"},' 
const mock_empty = ','
const mock_invalid_json = 'not_valid_json,'

fn test_get_sub_metadata() {
	result := decode_metadata(mock_json) or {panic('unexpected error: ${err}')}
	assert result.len == 2
	assert result[0].id == '123'
	assert result[0].title == "Test"
}

fn test_get_sub_metadata_empty() {
	result := decode_metadata(mock_empty) or {panic('unexpected error: ${err}')}
	assert result.len == 0
}

fn test_get_sub_metadata_invalid_json() {
	_ := decode_metadata(mock_invalid_json) or {
		assert err.msg().len > 0
		return
	}
	assert false, 'should have returned an error'
}
