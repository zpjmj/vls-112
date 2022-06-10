module vlang

import sym

const (
	all_ws = [byte(32), byte(9), byte(10), byte(11), byte(12),
		byte(13)] //空白字符
)

pub fn new_vlang_sym_context() ?sym.Context {
	mut context := sym.new_context()
	mut basic_symbol_priority_level := []string{}
	mut composite_symbol_priority_level := []string{}
	mut sub_composite_symbol_priority_level := []string{}
	mut match_fn_arr := []sym.FuncSymbolBool{}
	mut scope_index_map := map[string][]int{}
	mut parent := []string{}

	define01 := context.new_basic_symbol_define(basic_start_01, basic_end_01, basic_continue_01,
		false, 0, false, false)
	context.def_basic_symbol('ws', define01)?

	define02 := context.new_basic_symbol_define(basic_start_02, basic_end_02, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('import', define02)?

	define03 := context.new_basic_symbol_define(basic_start_03, basic_end_03, empty_fn_byte,
		true, 3, false, false)
	context.def_basic_symbol('pub', define03)?

	define04 := context.new_basic_symbol_define(basic_start_04, basic_end_04, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('struct', define04)?

	define05 := context.new_basic_symbol_define(basic_start_05, basic_end_05, empty_fn_byte,
		true, 2, false, false)
	context.def_basic_symbol('fn', define05)?

	define06 := context.new_basic_symbol_define(basic_start_06, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol('.', define06)?

	define07 := context.new_basic_symbol_define(basic_start_07, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol('{', define07)?

	define08 := context.new_basic_symbol_define(basic_start_08, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol('}', define08)?

	define09 := context.new_basic_symbol_define(basic_start_09, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol('(', define09)?

	define10 := context.new_basic_symbol_define(basic_start_10, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol(')', define10)?

	define11 := context.new_basic_symbol_define(basic_start_11, basic_end_11, empty_fn_byte,
		true, 2, false, false)
	context.def_basic_symbol(':=', define11)?

	define12 := context.new_basic_symbol_define(basic_start_12, basic_end_12, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('module', define12)?

	define13 := context.new_basic_symbol_define(basic_start_13, basic_end_13, basic_continue_13,
		false, 0, false, false)
	context.def_basic_symbol('name', define13)?

	define14 := context.new_basic_symbol_define(basic_start_14, basic_end_14, basic_continue_14,
		false, 0, true, false)
	context.def_basic_symbol('comment', define14)?

	define15 := context.new_basic_symbol_define(basic_start_15, basic_end_15, basic_continue_15,
		false, 0, true, false)
	context.def_basic_symbol('string_single_quotes', define15)?

	define16 := context.new_basic_symbol_define(basic_start_16, basic_end_16, basic_continue_16,
		false, 0, true, false)
	context.def_basic_symbol('string_double_quotes', define16)?

	define17 := context.new_basic_symbol_define(basic_start_17, basic_end_17, empty_fn_byte,
		true, 2, false, false)
	context.def_basic_symbol('as', define17)?

	define18 := context.new_basic_symbol_define(basic_start_18, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol(',', define18)?

	define19 := context.new_basic_symbol_define(basic_start_19, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol('[', define19)?

	define20 := context.new_basic_symbol_define(basic_start_20, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol(']', define20)?

	define21 := context.new_basic_symbol_define(basic_start_21, basic_end_21, basic_continue_21,
		false, 0, true, true)
	context.def_basic_symbol('real_string_single_quotes', define21)?

	define22 := context.new_basic_symbol_define(basic_start_22, basic_end_22, basic_continue_22,
		false, 0, true, true)
	context.def_basic_symbol('real_string_double_quotes', define22)?

	define23 := context.new_basic_symbol_define(basic_start_23, basic_end_23, empty_fn_byte,
		true, 3, false, false)
	context.def_basic_symbol('asm', define23)?

	define24 := context.new_basic_symbol_define(basic_start_24, basic_end_24, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('assert', define24)?

	define25 := context.new_basic_symbol_define(basic_start_25, basic_end_25, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('atomic', define25)?

	define26 := context.new_basic_symbol_define(basic_start_26, basic_end_26, empty_fn_byte,
		true, 5, false, false)
	context.def_basic_symbol('break', define26)?

	define27 := context.new_basic_symbol_define(basic_start_27, basic_end_27, empty_fn_byte,
		true, 4, false, false)
	context.def_basic_symbol('chan', define27)?

	define28 := context.new_basic_symbol_define(basic_start_28, basic_end_28, empty_fn_byte,
		true, 5, false, false)
	context.def_basic_symbol('const', define28)?

	define29 := context.new_basic_symbol_define(basic_start_29, basic_end_29, empty_fn_byte,
		true, 8, false, false)
	context.def_basic_symbol('continue', define29)?

	define30 := context.new_basic_symbol_define(basic_start_30, basic_end_30, empty_fn_byte,
		true, 5, false, false)
	context.def_basic_symbol('defer', define30)?

	define31 := context.new_basic_symbol_define(basic_start_31, basic_end_31, empty_fn_byte,
		true, 4, false, false)
	context.def_basic_symbol('else', define31)?

	define32 := context.new_basic_symbol_define(basic_start_32, basic_end_32, empty_fn_byte,
		true, 4, false, false)
	context.def_basic_symbol('enum', define32)?

	define33 := context.new_basic_symbol_define(basic_start_33, basic_end_33, empty_fn_byte,
		true, 5, false, false)
	context.def_basic_symbol('false', define33)?

	define34 := context.new_basic_symbol_define(basic_start_34, basic_end_34, empty_fn_byte,
		true, 3, false, false)
	context.def_basic_symbol('for', define34)?

	define35 := context.new_basic_symbol_define(basic_start_35, basic_end_35, empty_fn_byte,
		true, 2, false, false)
	context.def_basic_symbol('go', define35)?

	define36 := context.new_basic_symbol_define(basic_start_36, basic_end_36, empty_fn_byte,
		true, 4, false, false)
	context.def_basic_symbol('goto', define36)?

	define37 := context.new_basic_symbol_define(basic_start_37, basic_end_37, empty_fn_byte,
		true, 2, false, false)
	context.def_basic_symbol('if', define37)?

	define38 := context.new_basic_symbol_define(basic_start_38, basic_end_38, empty_fn_byte,
		true, 2, false, false)
	context.def_basic_symbol('in', define38)?

	define39 := context.new_basic_symbol_define(basic_start_39, basic_end_39, empty_fn_byte,
		true, 9, false, false)
	context.def_basic_symbol('interface', define39)?

	define40 := context.new_basic_symbol_define(basic_start_40, basic_end_40, empty_fn_byte,
		true, 2, false, false)
	context.def_basic_symbol('is', define40)?

	define41 := context.new_basic_symbol_define(basic_start_41, basic_end_41, empty_fn_byte,
		true, 4, false, false)
	context.def_basic_symbol('lock', define41)?

	define42 := context.new_basic_symbol_define(basic_start_42, basic_end_42, empty_fn_byte,
		true, 5, false, false)
	context.def_basic_symbol('match', define42)?

	define43 := context.new_basic_symbol_define(basic_start_43, basic_end_43, empty_fn_byte,
		true, 3, false, false)
	context.def_basic_symbol('mut', define43)?

	define44 := context.new_basic_symbol_define(basic_start_44, basic_end_44, empty_fn_byte,
		true, 4, false, false)
	context.def_basic_symbol('none', define44)?

	define45 := context.new_basic_symbol_define(basic_start_45, basic_end_45, empty_fn_byte,
		true, 2, false, false)
	context.def_basic_symbol('or', define45)?

	define46 := context.new_basic_symbol_define(basic_start_46, basic_end_46, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('return', define46)?

	define47 := context.new_basic_symbol_define(basic_start_47, basic_end_47, empty_fn_byte,
		true, 5, false, false)
	context.def_basic_symbol('rlock', define47)?

	define48 := context.new_basic_symbol_define(basic_start_48, basic_end_48, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('select', define48)?

	define49 := context.new_basic_symbol_define(basic_start_49, basic_end_49, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('shared', define49)?

	define50 := context.new_basic_symbol_define(basic_start_50, basic_end_50, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('sizeof', define50)?

	define51 := context.new_basic_symbol_define(basic_start_51, basic_end_51, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('static', define51)?

	define52 := context.new_basic_symbol_define(basic_start_52, basic_end_52, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('thread', define52)?

	define53 := context.new_basic_symbol_define(basic_start_53, basic_end_53, empty_fn_byte,
		true, 4, false, false)
	context.def_basic_symbol('true', define53)?

	define54 := context.new_basic_symbol_define(basic_start_54, basic_end_54, empty_fn_byte,
		true, 4, false, false)
	context.def_basic_symbol('type', define54)?

	define55 := context.new_basic_symbol_define(basic_start_55, basic_end_55, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('typeof', define55)?

	define56 := context.new_basic_symbol_define(basic_start_56, basic_end_56, empty_fn_byte,
		true, 8, false, false)
	context.def_basic_symbol('volatile', define56)?

	define57 := context.new_basic_symbol_define(basic_start_57, basic_end_57, empty_fn_byte,
		true, 5, false, false)
	context.def_basic_symbol('union', define57)?

	define58 := context.new_basic_symbol_define(basic_start_58, basic_end_58, empty_fn_byte,
		true, 6, false, false)
	context.def_basic_symbol('unsafe', define58)?

	define59 := context.new_basic_symbol_define(basic_start_59, basic_end_59, empty_fn_byte,
		true, 10, false, false)
	context.def_basic_symbol('__offsetof', define59)?

	define60 := context.new_basic_symbol_define(basic_start_60, basic_end_60, empty_fn_byte,
		true, 8, false, false)
	context.def_basic_symbol('__global', define60)?

	define61 := context.new_basic_symbol_define(basic_start_61, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol('<', define61)?

	define62 := context.new_basic_symbol_define(basic_start_62, empty_fn_byte2, empty_fn_byte,
		true, 1, false, false)
	context.def_basic_symbol('>', define62)?

	define63 := context.new_basic_symbol_define(basic_start_63, basic_end_63, basic_continue_63,
		false, 0, true, false)
	context.def_basic_symbol('rune', define63)?

	basic_symbol_priority_level << 'ws'
	basic_symbol_priority_level << 'comment'
	basic_symbol_priority_level << 'module'
	basic_symbol_priority_level << 'import'
	basic_symbol_priority_level << 'pub'
	basic_symbol_priority_level << 'struct'
	basic_symbol_priority_level << 'fn'
	basic_symbol_priority_level << 'as'
	basic_symbol_priority_level << 'asm'
	basic_symbol_priority_level << 'assert'
	basic_symbol_priority_level << 'atomic'
	basic_symbol_priority_level << 'break'
	basic_symbol_priority_level << 'chan'
	basic_symbol_priority_level << 'const'
	basic_symbol_priority_level << 'continue'
	basic_symbol_priority_level << 'defer'
	basic_symbol_priority_level << 'else'
	basic_symbol_priority_level << 'enum'
	basic_symbol_priority_level << 'false'
	basic_symbol_priority_level << 'for'
	basic_symbol_priority_level << 'go'
	basic_symbol_priority_level << 'goto'
	basic_symbol_priority_level << 'if'
	basic_symbol_priority_level << 'in'
	basic_symbol_priority_level << 'interface'
	basic_symbol_priority_level << 'is'
	basic_symbol_priority_level << 'lock'
	basic_symbol_priority_level << 'match'
	basic_symbol_priority_level << 'mut'
	basic_symbol_priority_level << 'none'
	basic_symbol_priority_level << 'or'
	basic_symbol_priority_level << 'return'
	basic_symbol_priority_level << 'rlock'
	basic_symbol_priority_level << 'select'
	basic_symbol_priority_level << 'shared'
	basic_symbol_priority_level << 'sizeof'
	basic_symbol_priority_level << 'static'
	basic_symbol_priority_level << 'thread'
	basic_symbol_priority_level << 'true'
	basic_symbol_priority_level << 'type'
	basic_symbol_priority_level << 'typeof'
	basic_symbol_priority_level << 'volatile'
	basic_symbol_priority_level << 'union'
	basic_symbol_priority_level << 'unsafe'
	basic_symbol_priority_level << '__offsetof'
	basic_symbol_priority_level << '__global'
	basic_symbol_priority_level << '.'
	basic_symbol_priority_level << ','
	basic_symbol_priority_level << '['
	basic_symbol_priority_level << ']'
	basic_symbol_priority_level << '{'
	basic_symbol_priority_level << '}'
	basic_symbol_priority_level << '('
	basic_symbol_priority_level << ')'
	basic_symbol_priority_level << '<'
	basic_symbol_priority_level << '>'
	basic_symbol_priority_level << ':='
	basic_symbol_priority_level << 'real_string_single_quotes'
	basic_symbol_priority_level << 'real_string_double_quotes'
	basic_symbol_priority_level << 'name'
	basic_symbol_priority_level << 'string_single_quotes'
	basic_symbol_priority_level << 'string_double_quotes'
	basic_symbol_priority_level << 'rune'
	context.basic_symbol_priority_level_push(basic_symbol_priority_level)?

	/*
	* match fn 命名
	* 基本符号名 + _ + flg
	* flg分类 ：0非必须  1必须有一个 2期待一个
	*/
	match_fn_arr = [ws_1, fn_1, ws_1, name_1, ws_0, lpar_1, rpar_2, lcbr_2, rcbr_2_end]
	define_c01 := context.new_composite_symbol_define(composite_start_pub, match_fn_arr)
	context.def_composite_symbol('{}pub_fn', define_c01)?

	match_fn_arr = [ws_1, name_1, ws_0, lpar_1, rpar_2, lcbr_2, rcbr_2_end]
	define_c02 := context.new_composite_symbol_define(composite_start_fn, match_fn_arr)
	context.def_composite_symbol('{}fn', define_c02)?

	match_fn_arr = [ws_1, fn_1, ws_0, lpar_1, rpar_2, ws_0, name_1, ws_0, lpar_1, rpar_2, lcbr_2,
		rcbr_2_end]
	define_c03 := context.new_composite_symbol_define(composite_start_pub, match_fn_arr)
	context.def_composite_symbol('{}pub_method', define_c03)?

	match_fn_arr = [ws_0, lpar_1, rpar_2, ws_0, name_1, ws_0, lpar_1, rpar_2, lcbr_2, rcbr_2_end]
	define_c04 := context.new_composite_symbol_define(composite_start_fn, match_fn_arr)
	context.def_composite_symbol('{}method', define_c04)?

	match_fn_arr = [ws_1, struct_1, ws_1, name_1, ws_0, lcbr_2, rcbr_2_end]
	define_c05 := context.new_composite_symbol_define(composite_start_pub, match_fn_arr)
	context.def_composite_symbol('{}pub_struct', define_c05)?

	match_fn_arr = [ws_1, name_1, ws_0, lcbr_2, rcbr_2_end]
	define_c06 := context.new_composite_symbol_define(composite_start_struct, match_fn_arr)
	context.def_composite_symbol('{}struct', define_c06)?

	match_fn_arr = [import_molule_continue_01, import_molule_continue_02]
	define_c07 := context.new_composite_symbol_define(composite_start_import, match_fn_arr)
	context.def_composite_symbol('{}import_molule', define_c07)?

	match_fn_arr = [ws_1, name_1, import_molule_continue_02]
	define_c08 := context.new_composite_symbol_define(composite_start_module, match_fn_arr)
	context.def_composite_symbol('{}module_decl', define_c08)?

	composite_symbol_priority_level << '{}pub_fn'
	composite_symbol_priority_level << '{}fn'
	composite_symbol_priority_level << '{}pub_method'
	composite_symbol_priority_level << '{}method'
	composite_symbol_priority_level << '{}pub_struct'
	composite_symbol_priority_level << '{}struct'
	composite_symbol_priority_level << '{}import_molule'
	composite_symbol_priority_level << '{}module_decl'
	context.composite_symbol_priority_level_push(composite_symbol_priority_level)?

	/*
	* sub_composite_symbol
	*/
	parent = []string{}
	parent << '{}pub_fn'
	parent << '{}fn'
	parent << '{}pub_method'
	parent << '{}method'
	parent << '()fn'
	scope_index_map = map[string][]int{}
	scope_index_map['{}pub_fn'] = [0, 1]
	scope_index_map['{}fn'] = [0, 1]
	scope_index_map['{}pub_method'] = [1, 2]
	scope_index_map['{}method'] = [1, 2]
	scope_index_map['()fn'] = []int{}
	match_fn_arr = [lsbr_0, rsbr_2, fn_dot_0, fn_name_1, ws_0, lpar_1, rpar_2_end]
	define_sc01 := context.new_composite_symbol_define(sub_composite_start_name, match_fn_arr)
	context.def_sub_composite_symbol('()fn', define_sc01, parent, scope_index_map)?

	sub_composite_symbol_priority_level << '()fn'
	context.sub_composite_symbol_priority_level_push(sub_composite_symbol_priority_level)?

	return context
}

//===========================================================================
fn empty_fn_symbol(input sym.Symbol) bool {
	return false
}

fn empty_fn_byte(input []byte) bool {
	return false
}

fn empty_fn_byte2(input []byte) bool {
	return true
}

fn key_com_start(input []byte, key byte) bool {
	if input.len > 0 {
		if input[0] == key {
			return true
		}
	}
	return false
}

fn key_com_end(input []byte, len int, match_str string) bool {
	if input.len == len {
		for i, s in match_str {
			if input[i] != s {
				return false
			}
		}

		end_byte := input[input.len - 1]

		if (end_byte > 0x2f && end_byte < 0x3a)
			|| (end_byte > 0x40 && end_byte < 0x5b)
			|| (end_byte > 0x60 && end_byte < 0x7b) || (end_byte == 0x5f) {
			return false
		}

		return true
	}
	return false
}

// ws
fn basic_start_01(input []byte) bool {
	for i in input {
		if i !in vlang.all_ws {
			return false
		}
	}
	return true
}

fn basic_end_01(input []byte) bool {
	return true
}

fn basic_continue_01(input []byte) bool {
	for i in input {
		if i !in vlang.all_ws {
			return false
		}
	}
	return true
}

// import
fn basic_start_02(input []byte) bool {
	return key_com_start(input, `i`)
}

fn basic_end_02(input []byte) bool {
	return key_com_end(input, 6, 'mport')
}

// pub
fn basic_start_03(input []byte) bool {
	return key_com_start(input, `p`)
}

fn basic_end_03(input []byte) bool {
	return key_com_end(input, 3, 'ub')
}

// struct
fn basic_start_04(input []byte) bool {
	return key_com_start(input, `s`)
}

fn basic_end_04(input []byte) bool {
	return key_com_end(input, 6, 'truct')
}

// fn
fn basic_start_05(input []byte) bool {
	return key_com_start(input, `f`)
}

fn basic_end_05(input []byte) bool {
	return key_com_end(input, 2, 'n')
}

//.
fn basic_start_06(input []byte) bool {
	return key_com_start(input, `.`)
}

//{
fn basic_start_07(input []byte) bool {
	return key_com_start(input, `{`)
}

//}
fn basic_start_08(input []byte) bool {
	return key_com_start(input, `}`)
}

//(
fn basic_start_09(input []byte) bool {
	return key_com_start(input, `(`)
}

//)
fn basic_start_10(input []byte) bool {
	return key_com_start(input, `)`)
}

//:=
fn basic_start_11(input []byte) bool {
	return key_com_start(input, `:`)
}

fn basic_end_11(input []byte) bool {
	return key_com_end(input, 2, '=')
}

// module
fn basic_start_12(input []byte) bool {
	return key_com_start(input, `m`)
}

fn basic_end_12(input []byte) bool {
	return key_com_end(input, 6, 'odule')
}

// name
fn basic_start_13(input []byte) bool {
	for i in input {
		if !((i > 0x40 && i < 0x5b) || (i > 0x60 && i < 0x7b) || i == 0x5f) {
			return false
		}
	}
	return true
}

fn basic_end_13(input []byte) bool {
	return true
}

fn basic_continue_13(input []byte) bool {
	for i in input {
		if !((i > 0x2f && i < 0x3a) || (i > 0x40 && i < 0x5b)
			|| (i > 0x60 && i < 0x7b) || (i == 0x5f)) {
			return false
		}
	}
	return true
}

// comment
fn basic_start_14(input []byte) bool {
	for i in input {
		if i != `/` {
			return false
		}
	}
	return true
}

fn basic_end_14(input []byte) bool {
	return !basic_continue_end_14_com(input, true)
}

fn basic_continue_14(input []byte) bool {
	return basic_continue_end_14_com(input, false)
}

fn basic_continue_end_14_com(input []byte, flg bool) bool {
	if input[0] == `/` {
		if input.len == 2 {
			if input[input.len - 1] == sym.scan_end {
				return false
			}
		} else if input.len > 2 {
			if input[input.len - 2] == `\n` || input[input.len - 1] == sym.scan_end {
				return false
			}
		}
		return true
	} else if input[0] == `*` {
		if input.len >= 4 {
			if input[input.len - 2] == `/` && input[input.len - 3] == `*` {
				mut left_num := 1
				mut right_num := 0

				for i := 1; i < input.len; i++ {
					first_byte := input[i]
					mut second_byte := byte(0b0)
					if i + 1 < input.len {
						second_byte = input[i + 1]
					}

					if first_byte == `/` && second_byte == `*` {
						left_num++
						i++
					} else if first_byte == `*` && second_byte == `/` {
						right_num++
						i++
					}
				}

				if left_num == right_num {
					return false
				}
				return true
			}
		}
		return true
	}

	return flg
}

// string
fn basic_continue_string_com(input []byte, quotes byte) bool {
	if input.len > 1 {
		if input[input.len - 2] == quotes {
			if input.len > 2 {
				prev_byte := input[input.len - 3]
				if prev_byte == `\\` {
					mut backslash_num := 0

					for i := input.len - 3; i >= 0; i-- {
						if input[i] == `\\` {
							backslash_num++
						} else {
							break
						}
					}

					if backslash_num % 2 != 0 {
						return true
					}
					return false
				}
				return false
			}
			return false
		}
	}
	return true
}

// string_single_quotes
fn basic_start_15(input []byte) bool {
	for i in input {
		if i != `'` {
			return false
		}
	}
	return true
}

fn basic_end_15(input []byte) bool {
	return !basic_continue_string_com(input, `'`)
}

fn basic_continue_15(input []byte) bool {
	return basic_continue_string_com(input, `'`)
}

// string_double_quotes
fn basic_start_16(input []byte) bool {
	for i in input {
		if i != `"` {
			return false
		}
	}
	return true
}

fn basic_end_16(input []byte) bool {
	return !basic_continue_string_com(input, `"`)
}

fn basic_continue_16(input []byte) bool {
	return basic_continue_string_com(input, `"`)
}

// as
fn basic_start_17(input []byte) bool {
	return key_com_start(input, `a`)
}

fn basic_end_17(input []byte) bool {
	return key_com_end(input, 2, 's')
}

//,
fn basic_start_18(input []byte) bool {
	return key_com_start(input, `,`)
}

//[
fn basic_start_19(input []byte) bool {
	return key_com_start(input, `[`)
}

//]
fn basic_start_20(input []byte) bool {
	return key_com_start(input, `]`)
}

// real_string_single_quotes
// real_string_double_quotes
fn real_string_com_end(input []byte, quotes byte) bool {
	if _likely_(input.len > 2) {
		if input[0] != quotes {
			return false
		}

		if input[input.len - 2] != quotes {
			return false
		}
		return true
	}

	return false
}

fn real_string_com_continue(input []byte, quotes byte) bool {
	if input[input.len - 1] == sym.scan_end {
		return false
	}

	if _likely_(input.len > 2) {
		if input[0] != quotes {
			return false
		}

		if input[input.len - 2] == quotes {
			return false
		}
	}

	return true
}

fn basic_start_21(input []byte) bool {
	for i in input {
		if i != `r` {
			return false
		}
	}
	return true
}

fn basic_start_22(input []byte) bool {
	for i in input {
		if i != `r` {
			return false
		}
	}
	return true
}

fn basic_end_21(input []byte) bool {
	return real_string_com_end(input, `'`)
}

fn basic_end_22(input []byte) bool {
	return real_string_com_end(input, `"`)
}

fn basic_continue_21(input []byte) bool {
	return real_string_com_continue(input, `'`)
}

fn basic_continue_22(input []byte) bool {
	return real_string_com_continue(input, `"`)
}

// asm
fn basic_start_23(input []byte) bool {
	return key_com_start(input, `a`)
}

fn basic_end_23(input []byte) bool {
	return key_com_end(input, 3, 'sm')
}

// assert
fn basic_start_24(input []byte) bool {
	return key_com_start(input, `a`)
}

fn basic_end_24(input []byte) bool {
	return key_com_end(input, 6, 'ssert')
}

// atomic
fn basic_start_25(input []byte) bool {
	return key_com_start(input, `a`)
}

fn basic_end_25(input []byte) bool {
	return key_com_end(input, 6, 'tomic')
}

// break
fn basic_start_26(input []byte) bool {
	return key_com_start(input, `b`)
}

fn basic_end_26(input []byte) bool {
	return key_com_end(input, 5, 'reak')
}

// chan
fn basic_start_27(input []byte) bool {
	return key_com_start(input, `c`)
}

fn basic_end_27(input []byte) bool {
	return key_com_end(input, 4, 'han')
}

// const
fn basic_start_28(input []byte) bool {
	return key_com_start(input, `c`)
}

fn basic_end_28(input []byte) bool {
	return key_com_end(input, 5, 'onst')
}

// continue
fn basic_start_29(input []byte) bool {
	return key_com_start(input, `c`)
}

fn basic_end_29(input []byte) bool {
	return key_com_end(input, 8, 'ontinue')
}

// defer
fn basic_start_30(input []byte) bool {
	return key_com_start(input, `d`)
}

fn basic_end_30(input []byte) bool {
	return key_com_end(input, 5, 'efer')
}

// else
fn basic_start_31(input []byte) bool {
	return key_com_start(input, `e`)
}

fn basic_end_31(input []byte) bool {
	return key_com_end(input, 4, 'lse')
}

// enum
fn basic_start_32(input []byte) bool {
	return key_com_start(input, `e`)
}

fn basic_end_32(input []byte) bool {
	return key_com_end(input, 4, 'num')
}

// false
fn basic_start_33(input []byte) bool {
	return key_com_start(input, `f`)
}

fn basic_end_33(input []byte) bool {
	return key_com_end(input, 5, 'alse')
}

// for
fn basic_start_34(input []byte) bool {
	return key_com_start(input, `f`)
}

fn basic_end_34(input []byte) bool {
	return key_com_end(input, 3, 'or')
}

// go
fn basic_start_35(input []byte) bool {
	return key_com_start(input, `g`)
}

fn basic_end_35(input []byte) bool {
	return key_com_end(input, 2, 'o')
}

// goto
fn basic_start_36(input []byte) bool {
	return key_com_start(input, `g`)
}

fn basic_end_36(input []byte) bool {
	return key_com_end(input, 4, 'oto')
}

// if
fn basic_start_37(input []byte) bool {
	return key_com_start(input, `i`)
}

fn basic_end_37(input []byte) bool {
	return key_com_end(input, 2, 'f')
}

// in
fn basic_start_38(input []byte) bool {
	return key_com_start(input, `i`)
}

fn basic_end_38(input []byte) bool {
	return key_com_end(input, 2, 'n')
}

// interface
fn basic_start_39(input []byte) bool {
	return key_com_start(input, `i`)
}

fn basic_end_39(input []byte) bool {
	return key_com_end(input, 9, 'nterface')
}

// is
fn basic_start_40(input []byte) bool {
	return key_com_start(input, `i`)
}

fn basic_end_40(input []byte) bool {
	return key_com_end(input, 2, 's')
}

// lock
fn basic_start_41(input []byte) bool {
	return key_com_start(input, `l`)
}

fn basic_end_41(input []byte) bool {
	return key_com_end(input, 4, 'ock')
}

// match
fn basic_start_42(input []byte) bool {
	return key_com_start(input, `m`)
}

fn basic_end_42(input []byte) bool {
	return key_com_end(input, 5, 'atch')
}

// mut
fn basic_start_43(input []byte) bool {
	return key_com_start(input, `m`)
}

fn basic_end_43(input []byte) bool {
	return key_com_end(input, 3, 'ut')
}

// none
fn basic_start_44(input []byte) bool {
	return key_com_start(input, `n`)
}

fn basic_end_44(input []byte) bool {
	return key_com_end(input, 4, 'one')
}

// or
fn basic_start_45(input []byte) bool {
	return key_com_start(input, `o`)
}

fn basic_end_45(input []byte) bool {
	return key_com_end(input, 2, 'r')
}

// return
fn basic_start_46(input []byte) bool {
	return key_com_start(input, `r`)
}

fn basic_end_46(input []byte) bool {
	return key_com_end(input, 6, 'eturn')
}

// rlock
fn basic_start_47(input []byte) bool {
	return key_com_start(input, `r`)
}

fn basic_end_47(input []byte) bool {
	return key_com_end(input, 5, 'lock')
}

// select
fn basic_start_48(input []byte) bool {
	return key_com_start(input, `s`)
}

fn basic_end_48(input []byte) bool {
	return key_com_end(input, 6, 'elect')
}

// shared
fn basic_start_49(input []byte) bool {
	return key_com_start(input, `s`)
}

fn basic_end_49(input []byte) bool {
	return key_com_end(input, 6, 'hared')
}

// sizeof
fn basic_start_50(input []byte) bool {
	return key_com_start(input, `s`)
}

fn basic_end_50(input []byte) bool {
	return key_com_end(input, 6, 'izeof')
}

// static
fn basic_start_51(input []byte) bool {
	return key_com_start(input, `s`)
}

fn basic_end_51(input []byte) bool {
	return key_com_end(input, 6, 'tatic')
}

// thread
fn basic_start_52(input []byte) bool {
	return key_com_start(input, `t`)
}

fn basic_end_52(input []byte) bool {
	return key_com_end(input, 6, 'hread')
}

// true
fn basic_start_53(input []byte) bool {
	return key_com_start(input, `t`)
}

fn basic_end_53(input []byte) bool {
	return key_com_end(input, 4, 'rue')
}

// type
fn basic_start_54(input []byte) bool {
	return key_com_start(input, `t`)
}

fn basic_end_54(input []byte) bool {
	return key_com_end(input, 4, 'ype')
}

// typeof
fn basic_start_55(input []byte) bool {
	return key_com_start(input, `t`)
}

fn basic_end_55(input []byte) bool {
	return key_com_end(input, 6, 'ypeof')
}

// volatile
fn basic_start_56(input []byte) bool {
	return key_com_start(input, `v`)
}

fn basic_end_56(input []byte) bool {
	return key_com_end(input, 8, 'olatile')
}

// union
fn basic_start_57(input []byte) bool {
	return key_com_start(input, `u`)
}

fn basic_end_57(input []byte) bool {
	return key_com_end(input, 5, 'nion')
}

// unsafe
fn basic_start_58(input []byte) bool {
	return key_com_start(input, `u`)
}

fn basic_end_58(input []byte) bool {
	return key_com_end(input, 6, 'nsafe')
}

//__offsetof
fn basic_start_59(input []byte) bool {
	return key_com_start(input, `_`)
}

fn basic_end_59(input []byte) bool {
	return key_com_end(input, 10, '_offsetof')
}

//__global
fn basic_start_60(input []byte) bool {
	return key_com_start(input, `_`)
}

fn basic_end_60(input []byte) bool {
	return key_com_end(input, 8, '_global')
}

//<
fn basic_start_61(input []byte) bool {
	return key_com_start(input, `<`)
}

//>
fn basic_start_62(input []byte) bool {
	return key_com_start(input, `>`)
}

// rune
fn basic_start_63(input []byte) bool {
	for i in input {
		if i != `\`` { // 0x60
			return false
		}
	}
	return true
}

fn basic_end_63(input []byte) bool {
	return !basic_continue_string_com(input, `\``)
}

fn basic_continue_63(input []byte) bool {
	return basic_continue_string_com(input, `\``)
}

//====================================================================
// pub fn
fn composite_start_pub(input sym.Symbol) bool {
	if input.name == 'pub' {
		return true
	}
	return false
}

// fn
fn composite_start_fn(input sym.Symbol) bool {
	if input.name == 'fn' {
		return true
	}
	return false
}

// struct
fn composite_start_struct(input sym.Symbol) bool {
	if input.name == 'struct' {
		return true
	}
	return false
}

// struct
fn composite_start_import(input sym.Symbol) bool {
	if input.name == 'import' {
		return true
	}
	return false
}

// module
fn composite_start_module(input sym.Symbol) bool {
	if input.name == 'module' {
		return true
	}
	return false
}

//================================================
// composite match common function
fn ws_1(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == 'ws' {
		return true, 1, 1, 0
	}
	return false, 0, 0, 0
}

fn fn_1(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == 'fn' {
		return true, 1, 1, 0
	}
	return false, 0, 0, 0
}

fn struct_1(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == 'struct' {
		return true, 1, 1, 0
	}
	return false, 0, 0, 0
}

fn name_1(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == 'name' {
		return true, 1, 1, 0
	}
	return false, 0, 0, 0
}

fn ws_0(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == 'ws' {
		return true, 1, 1, 0
	}
	return true, 0, 1, 0
}

fn lpar_1(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == '(' {
		scope_index_arr << input.start_index
		return true, 1, 1, 1
	}
	return false, 0, 0, 0
}

fn rpar_2(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	mut tmp_tier := tier

	if input.name == '(' {
		tmp_tier++
		return true, 1, 0, tmp_tier
	}

	if input.name == ')' {
		tmp_tier--
		if tmp_tier == 0 {
			scope_index_arr << input.start_index
			return true, 1, 1, 0
		}
	}

	return true, 1, 0, tmp_tier
}

fn lcbr_2(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == '{' {
		scope_index_arr << input.start_index
		return true, 1, 1, 1
	}

	return true, 1, 0, 0
}

fn rcbr_2_end(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	mut tmp_tier := tier

	if input.name == '{' {
		tmp_tier++
		return true, 1, 0, tmp_tier
	}

	if input.name == '}' {
		tmp_tier--
		if tmp_tier == 0 {
			scope_index_arr << input.start_index
			return false, 0, 0, 0
		}
	}

	return true, 1, 0, tmp_tier
}

fn lsbr_0(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == '[' {
		scope_index_arr << input.start_index
		return true, 1, 1, 1
	}

	return true, 0, 2, 0
}

fn rsbr_2(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	mut tmp_tier := tier

	if input.name == '[' {
		tmp_tier++
		return true, 1, 0, tmp_tier
	}

	if input.name == ']' {
		tmp_tier--
		if tmp_tier == 0 {
			scope_index_arr << input.start_index
			return true, 1, -1, 0
		}
	}

	return true, 1, 0, tmp_tier
}

fn import_molule_continue_01(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name in ['name', '.', 'as', '{', '}', ',', 'ws'] {
		return true, 1, 0, 0
	}
	return true, -1, 1, 0
}

fn import_molule_continue_02(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name != 'ws' {
		return true, 0, 1, 0
	}

	text := input.get_text()

	mut flg := 0

	for i in text {
		if i == `\n` {
			flg++
		}
	}

	if flg > 0 {
		return false, 0, 0, 0
	}

	return true, 0, 1, 0
}

//====================================================================
//()fn
fn sub_composite_start_name(input sym.Symbol) bool {
	if input.name == 'name' {
		return true
	}
	return false
}

fn fn_dot_0(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == '.' {
		return true, 1, 1, 0
	}
	return true, 0, 2, 0
}

fn fn_name_1(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	if input.name == 'name' {
		return true, 1, -3, 0
	}
	return false, 0, 0, 0
}

fn rpar_2_end(input sym.Symbol, tier int, mut scope_index_arr []int) (bool, int, int, int) {
	mut tmp_tier := tier

	if input.name == '(' {
		tmp_tier++
		return true, 1, 0, tmp_tier
	}

	if input.name == ')' {
		tmp_tier--
		if tmp_tier == 0 {
			scope_index_arr << input.start_index
			return false, 0, 0, 0
		}
	}

	return true, 1, 0, tmp_tier
}
