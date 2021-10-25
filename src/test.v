// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module scanner

import math.mathutil
import os
import strconv
import v.token
import v.pref
import v.util
import v.vet
import v.errors
import v.ast

const (
	single_quote = `'`
	double_quote = `"`
	// char used as number separator
	num_sep      = `_`
	b_lf         = 10
	b_cr         = 13
	backslash    = `\\`
)


pub fn new_scanner_file(file_path string, comments_mode CommentsMode, pref &pref.Preferences) &Scanner {
	if !os.is_file(file_path) {
		verror('$file_path is not a file')
	}
	raw_text := util.read_file(file_path) or {
		verror(err.msg)
		return voidptr(0)
	}
	mut s := &Scanner{
		pref: pref
		text: raw_text
		is_print_line_on_error: true
		is_print_colored_error: true
		is_print_rel_paths_on_error: true
		is_fmt: pref.is_fmt
		comments_mode: comments_mode
		file_path: file_path
		file_base: os.base(file_path)
	}
	s.init_scanner()
	return s
}
