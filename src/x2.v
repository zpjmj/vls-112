// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module os

pub fn dir (opath string) string {
	if opath == '' {
		return '.'
	}
	path := opath.replace_each(['/', path_separator, r'\', path_separator])
	pos := path.last_index(path_separator) or { return '.' }
	if pos == 0 && path_separator == '/' {
		return '/'
	}
	return path[..pos]
}

