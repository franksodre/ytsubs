module main

import json2

@[soa]
struct Subtitle {
	id 	 					string
	title					string
	original_url 	string
	size 					u64
}

fn handle_video(metadata string) []Subtitle {
	subtitle := json2.decode[[]Subtitle](metadata) or {
		eprintln("Failed to decode json, error: ${err}")
		exit(1)
	}

	return subtitle
}

@[inline]
fn view_html_download(filepath string, content ?string) string {
	return '<a href="/subs/${filepath}" download class="text-semibold hover:underline">${content or {''}}</a>'
}

// I could just pass the id from b once that's the only thing being use.
// and this is a pretty niche function.
fn diff_sub(a []Subtitle, b []Subtitle) []Subtitle {
	mut m := map[string]bool{}
	for _, s in b {
		m[s.id] = true
	}

	diff := a.filter(!m[it.id])
	return diff
}
