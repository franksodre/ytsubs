module repo
import entity { Info, InfoPlaylist }

pub struct UseCase {
pub:
	cache Repository
}

// The code is the youtube id
pub fn (u UseCase) get_item[T](code string) (T, bool) {
	$if T is entity.Info {
		item := u.cache.lookup[entity.Info](code, lookup_info)
		if item != Info{} {
			return item, true
		}
		return T{}, false
	} $else {
		item := u.cache.lookup[entity.InfoPlaylist](code, lookup_info_playlist)
		if item != InfoPlaylist{} {
			return item, true
		}
		return T{}, false
	}
}

pub fn (u UseCase) add_item[T](code string, item T) ! {
	$if T is entity.Info {
		info := u.cache.lookup[entity.Info](code, lookup_info)
		if info != Info{} { return }
		u.cache.add_key[Info](item, add_key_info)!
	} $else {
		info := u.cache.lookup[entity.InfoPlaylist](code, lookup_info_playlist)
		if info != InfoPlaylist{} { return }
		u.cache.add_key[InfoPlaylist](item, add_key_playlist)!
	}
}
