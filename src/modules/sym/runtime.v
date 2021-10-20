module sym

import os
import strings

//运行时提供运行时必须的外部环境
[heap]
pub struct Runtime{
pub mut:
	//当前的context
	context &Context
	//所有待解析的文件路径数组
	file_path string
	//所有待解析的字符串
	buff string
	//所有基本符号
	all_basic_symbol []Symbol
	//所有组合符号
	all_composite_symbol []Symbol
	//扫描器对象
	scanner Scanner
}

pub fn (mut r Runtime) basic_symbol_type_str() string{
	mut all_symbol := r.all_basic_symbol
	mut sb := strings.new_builder(1000)
	mut no := 0
	mut no_str := ''

	sb.write_string('\n')
	sb.write_string('BASIC:========================================================\n')
	no_str = ('0000' + '$no')
	no_str = no_str[no_str.len -4 .. no_str.len] + ': '
	sb.write_string(no_str)

	for i,s in all_symbol{
		if s.typ != .composite{
			if s.typ == .undefined{
				sb.write_string('undefined')
			}else{
				sb.write_string(s.name)
			}
			sb.write_string(' ')
			if (i+1)%10 == 0 {
				sb.write_string('\n')
				no+=10
				no_str = ('0000' + '$no')
				no_str = no_str[no_str.len -4 .. no_str.len] + ': '
				sb.write_string(no_str)
			} 
		}

	}
	sb.write_string('\n')
	sb.write_string('\n')
	res := sb.str()
	unsafe { sb.free() }
	return res
}

pub fn (mut r Runtime) composite_symbol_type_str() string{
	mut all_symbol := r.all_composite_symbol
	mut sb := strings.new_builder(1000)
	mut no := 0
	mut no_str := ''
	sb.write_string('\n')
	sb.write_string('COMPOSITE:====================================================\n')
	no_str = ('0000' + '$no')
	no_str = no_str[no_str.len -4 .. no_str.len] + ': '
	sb.write_string(no_str)

	for i,s in all_symbol{

		if s.typ == .composite || s.typ == .sub_composite{
			sb.write_string(s.name)
			sb.write_string(' ')
			if (i+1)%10 == 0 {
				sb.write_string('\n')
				no+=10
				no_str = ('0000' + '$no')
				no_str = no_str[no_str.len -4 .. no_str.len] + ': '
				sb.write_string(no_str)
			} 
		}

	}
	sb.write_string('\n')
	sb.write_string('\n')
	res := sb.str()
	unsafe { sb.free() }
	return res
}


pub fn new_runtime(c &Context) Runtime{
	return Runtime{
		context:c
	}
}

//开始解析基本符号
pub fn (mut r Runtime) parse_basic_symbol()?{
	mut buff := r.buff

	if buff.len == 0{
		buff = os.read_file(r.file_path)?
	}

	r.scanner = new_scanner(buff)

	r.parse_basic_symbol__()?
}
fn (mut r Runtime) parse_basic_symbol__()?{
	unsafe{
		mut scanner := &r.scanner
		mut undefine_start:=false
		mut undefine_start_line:=0
		mut undefine_start_word_character:=0
		mut undefine_start_byte_character:=0	
		mut undefine_start_word_pos:=0
		mut undefine_start_byte_pos:=0
		mut start_line:=0
		mut start_word_character:=0
		mut start_byte_character:=0
		mut	start_word_pos:=scanner.word_pos
		mut	start_byte_pos:=scanner.byte_pos

		for{
	next:
			start_word_pos = scanner.word_pos
			start_byte_pos = scanner.byte_pos
			start_line = scanner.line
			start_word_character = scanner.word_pos - scanner.prev_line_word_pos
			start_byte_character = scanner.byte_pos - scanner.prev_line_byte_pos

			word := scanner.scan()?

			if scanner.is_end{
				break
			}

			for basic_symbol_index in r.context.basic_symbol_priority_level{
				basic_symbol := r.context.all_basic_symbol[basic_symbol_index]
				basic_symbol_define := basic_symbol.define
				
				if basic_symbol_define.is_start(word){
					scanner.clean_stack()
					if basic_symbol_define.is_fixed_length{
						if basic_symbol_define.len > 1 {
							mut after_word := []byte{}
							scanner.pushd()
							for i:=1;i<basic_symbol_define.len + 1;i++{
								next_word := scanner.scan()?
								if scanner.is_end{
									after_word << scan_end
									break
								}
								after_word << next_word
							}

							if !basic_symbol_define.is_end(after_word){
								scanner.popd()
								continue
							}
							scanner.prev_scan()
						}

						if undefine_start{
							r.all_basic_symbol << Symbol{
								name:''
								typ:.undefined
								scanner:scanner
								text_range:Range{
									start:undefine_start_word_pos
									end:start_word_pos
									start_line:undefine_start_line
									start_character:undefine_start_word_character
									end_line:start_line
									end_character:start_word_character
								}
								byte_range:Range{
									start:undefine_start_byte_pos
									end:start_byte_pos
									start_line:undefine_start_line
									start_character:undefine_start_byte_character
									end_line:start_line
									end_character:start_byte_character
								}
								start_index:r.all_basic_symbol.len
							}
							undefine_start = false
						}

						r.all_basic_symbol << Symbol{
							name:basic_symbol.name
							typ:.basic
							scanner:scanner
							text_range:Range{
								start:start_word_pos
								end:scanner.word_pos
								start_line:start_line
								start_character:start_word_character
								end_line:scanner.line
								end_character:scanner.word_pos - scanner.prev_line_word_pos
							}
							byte_range:Range{
								start:start_byte_pos
								end:scanner.byte_pos
								start_line:start_line
								start_character:start_byte_character
								end_line:scanner.line
								end_character:scanner.byte_pos - scanner.prev_line_byte_pos
							}
							start_index:r.all_basic_symbol.len
						}
						goto next
					}else{
						mut after_word := []byte{}
						scanner.pushd()
						for {
							next_word := scanner.scan()?
							if scanner.is_end{
								after_word << scan_end
								break
							}

							after_word << next_word

							if basic_symbol_define.continue_fn_input_all{
								if !basic_symbol_define.is_continue(after_word){
									break
								}
							}else{
								if !basic_symbol_define.is_continue(next_word){
									break
								}
							}							
						}

						scanner.prev_scan()
						if basic_symbol_define.is_end(after_word){
							if undefine_start{
								r.all_basic_symbol << Symbol{
									name:''
									typ:.undefined
									scanner:scanner
									text_range:Range{
										start:undefine_start_word_pos
										end:start_word_pos
										start_line:undefine_start_line
										start_character:undefine_start_word_character
										end_line:start_line
										end_character:start_word_character
									}
									byte_range:Range{
										start:undefine_start_byte_pos
										end:start_byte_pos
										start_line:undefine_start_line
										start_character:undefine_start_byte_character
										end_line:start_line
										end_character:start_byte_character
									}
									start_index:r.all_basic_symbol.len
								}
								undefine_start = false
							}

							r.all_basic_symbol << Symbol{
								name:basic_symbol.name
								typ:.basic
								scanner:scanner
								text_range:Range{
									start:start_word_pos
									end:scanner.word_pos
									start_line:start_line
									start_character:start_word_character
									end_line:scanner.line
									end_character:scanner.word_pos - scanner.prev_line_word_pos
								}
								byte_range:Range{
									start:start_byte_pos
									end:scanner.byte_pos
									start_line:start_line
									start_character:start_byte_character
									end_line:scanner.line
									end_character:scanner.byte_pos - scanner.prev_line_byte_pos
								}
								start_index:r.all_basic_symbol.len
							}
							goto next
						}else{

							if basic_symbol_define.on_error_skip{
								scanner.popd()
								continue
							}

							if undefine_start{
								r.all_basic_symbol << Symbol{
									name:''
									typ:.undefined
									scanner:scanner
									text_range:Range{
										start:undefine_start_word_pos
										end:scanner.word_pos
										start_line:undefine_start_line
										start_character:undefine_start_word_character
										end_line:start_line
										end_character:start_word_character
									}
									byte_range:Range{
										start:undefine_start_byte_pos
										end:scanner.byte_pos
										start_line:undefine_start_line
										start_character:undefine_start_byte_character
										end_line:start_line
										end_character:start_byte_character
									}
									start_index:r.all_basic_symbol.len
								}
								undefine_start = false
							}else{
								r.all_basic_symbol << Symbol{
									name:''
									typ:.undefined
									scanner:scanner
									text_range:Range{
										start:start_word_pos
										end:scanner.word_pos
										start_line:start_line
										start_character:start_word_character
										end_line:scanner.line
										end_character:scanner.word_pos - scanner.prev_line_word_pos
									}
									byte_range:Range{
										start:start_byte_pos
										end:scanner.byte_pos
										start_line:start_line
										start_character:start_byte_character
										end_line:scanner.line
										end_character:scanner.byte_pos - scanner.prev_line_byte_pos
									}
									start_index:r.all_basic_symbol.len
								}
							}
							goto next
						}
					}
				}
			}

			if !undefine_start{		
				undefine_start_word_pos = start_word_pos
				undefine_start_byte_pos = start_byte_pos
				undefine_start_line = start_line
				undefine_start_word_character = start_word_character
				undefine_start_byte_character = start_byte_character
				undefine_start = true
			}
		}
		scanner.clean_stack()
	}

}

//开始解析组合符号
pub fn (mut r Runtime) parse_composite_symbol()?{
	r.parse_composite_symbol__() or {
		return
	}
}
fn (mut r Runtime) parse_composite_symbol__()?{
	len := r.all_basic_symbol.len

	for index := 0;index < len;index++{
		basic_symbol := r.all_basic_symbol[index]?
	
		for composite_symbol_index in r.context.composite_symbol_priority_level{
			composite_symbol := &r.context.all_composite_symbol[composite_symbol_index]
			mut composite_symbol_define := &composite_symbol.define
			
			if composite_symbol_define.is_start(basic_symbol){
				mut next_basic_symbol := basic_symbol
				mut next_index := index + 1
				mut match_flg := false
				mut tier := 0
				mut scope_index_arr := []int{}

				for {
					next_basic_symbol = r.all_basic_symbol[next_index]?
					flg,symbol_step,match_fn_step,tier_tmp := composite_symbol_define.can_continue(next_basic_symbol,tier,mut scope_index_arr)	
					tier = tier_tmp

					if flg && symbol_step == 0 && match_fn_step==0{
						break
					}

					next_index += symbol_step
					composite_symbol_define.match_fn_index+=match_fn_step

					if !flg{
						if composite_symbol_define.match_fn_index == composite_symbol_define.match_fn_arr.len - 1{	
							match_flg = true
						}

						composite_symbol_define.match_fn_index = 0
						composite_symbol_define.can_continue = composite_symbol_define.match_fn_arr[0]
						break
					}

					if composite_symbol_define.match_fn_index == composite_symbol_define.match_fn_arr.len{
						composite_symbol_define.match_fn_index = 0
						composite_symbol_define.can_continue = composite_symbol_define.match_fn_arr[0]
						break
					}

					composite_symbol_define.can_continue = composite_symbol_define.match_fn_arr[composite_symbol_define.match_fn_index]
				}

				if match_flg{
					r.all_composite_symbol << Symbol{
						name:composite_symbol.name
						typ:.composite
						scanner:basic_symbol.scanner
						text_range:Range{
							start:basic_symbol.text_range.start
							end:next_basic_symbol.text_range.end
							start_line:basic_symbol.text_range.start_line
							start_character:basic_symbol.text_range.start_character
							end_line:next_basic_symbol.text_range.end_line
							end_character:next_basic_symbol.text_range.end_character
						}
						byte_range:Range{
							start:basic_symbol.byte_range.start
							end:next_basic_symbol.byte_range.end
							start_line:basic_symbol.byte_range.start_line
							start_character:basic_symbol.byte_range.start_character
							end_line:next_basic_symbol.byte_range.end_line
							end_character:next_basic_symbol.byte_range.end_character
						}
						start_index:index
						end_index:next_index
						scope:scope_index_arr
					}
					index = next_index
				}
			}
		}
	}
}

//开始解析组合符号_scope
pub fn (mut r Runtime) parse_sub_composite_symbol()?{
	r.parse_sub_composite_symbol__() or {
		return
	}
}

fn (mut r Runtime) parse_sub_composite_symbol__()?{

	for sub_symbol_index in r.context.sub_composite_symbol_priority_level{
		sub_symbol := &r.context.all_sub_composite_symbol[sub_symbol_index]
		
		for composite_symbol in r.all_composite_symbol{
			if composite_symbol.name !in sub_symbol.parent{
				continue
			}

			if composite_symbol.name !in sub_symbol.scope_index{
				continue
			}

			scope_index := sub_symbol.scope_index[composite_symbol.name]
			mut basic_start_index := 0
			mut basic_end_index := 0

			if scope_index.len == 0{
				basic_start_index = composite_symbol.start_index
				basic_end_index = composite_symbol.end_index

				r.parse_single_sub_composite_symbol__(basic_start_index,basic_end_index,&sub_symbol.composite_symbol)?

			}else{
				for i in scope_index{
					si := i * 2
					si_2 := si + 1

					if si_2 >= composite_symbol.scope.len{
						continue
					}

					basic_start_index = composite_symbol.scope[si]
					basic_end_index = composite_symbol.scope[si_2]

					r.parse_single_sub_composite_symbol__(basic_start_index,basic_end_index,&sub_symbol.composite_symbol)?
				}
			}
		}
	}
}

fn (mut r Runtime) parse_single_sub_composite_symbol__(basic_start_index int,basic_end_index int,composite_symbol &CompositeSymbol)?{
	for index := basic_start_index + 1;index < basic_end_index;index++{
		basic_symbol := r.all_basic_symbol[index]?
		//composite_symbol := c_symbol
		mut composite_symbol_define := &composite_symbol.define
		
		if composite_symbol_define.is_start(basic_symbol){
			mut next_basic_symbol := basic_symbol
			mut next_index := index + 1
			mut match_flg := false
			mut tier := 0
			mut scope_index_arr := []int{}

			for {
				next_basic_symbol = r.all_basic_symbol[next_index]?
				flg,symbol_step,match_fn_step,tier_tmp := composite_symbol_define.can_continue(next_basic_symbol,tier,mut scope_index_arr)	
				tier = tier_tmp

				if flg && symbol_step == 0 && match_fn_step==0{
					break
				}

				next_index += symbol_step
				composite_symbol_define.match_fn_index+=match_fn_step

				if !flg{
					if composite_symbol_define.match_fn_index == composite_symbol_define.match_fn_arr.len - 1{	
						match_flg = true
					}

					composite_symbol_define.match_fn_index = 0
					composite_symbol_define.can_continue = composite_symbol_define.match_fn_arr[0]
					break
				}

				if composite_symbol_define.match_fn_index == composite_symbol_define.match_fn_arr.len{
					composite_symbol_define.match_fn_index = 0
					composite_symbol_define.can_continue = composite_symbol_define.match_fn_arr[0]
					break
				}

				composite_symbol_define.can_continue = composite_symbol_define.match_fn_arr[composite_symbol_define.match_fn_index]
			}

			if match_flg{
				r.all_composite_symbol << Symbol{
					name:composite_symbol.name
					typ:.sub_composite
					scanner:basic_symbol.scanner
					text_range:Range{
						start:basic_symbol.text_range.start
						end:next_basic_symbol.text_range.end
						start_line:basic_symbol.text_range.start_line
						start_character:basic_symbol.text_range.start_character
						end_line:next_basic_symbol.text_range.end_line
						end_character:next_basic_symbol.text_range.end_character
					}
					byte_range:Range{
						start:basic_symbol.byte_range.start
						end:next_basic_symbol.byte_range.end
						start_line:basic_symbol.byte_range.start_line
						start_character:basic_symbol.byte_range.start_character
						end_line:next_basic_symbol.byte_range.end_line
						end_character:next_basic_symbol.byte_range.end_character
					}
					start_index:index
					end_index:next_index
					scope:scope_index_arr
				}
				index = next_index
			}
		}	
	}
}

pub fn (r Runtime) get_fn_name(c_symbol Symbol)string{
	if c_symbol.start_index < 0 || c_symbol.start_index >= r.all_basic_symbol.len{
		return ''
	}

	if c_symbol.end_index < 0 || c_symbol.end_index >= r.all_basic_symbol.len{
		return ''
	}

	if !(c_symbol.name == '{}fn' || c_symbol.name == '{}pub_fn'){
		return ''
	}	

	for i:=c_symbol.start_index;i<=c_symbol.end_index;i++{
		b_symbol := r.all_basic_symbol[i]
		if b_symbol.name == 'fn'{
			return r.all_basic_symbol[i+2].get_text()
		}
	}
	return ''
}

pub fn (r Runtime) get_fn_symbol(c_symbol Symbol)Symbol{
	if c_symbol.start_index < 0 || c_symbol.start_index >= r.all_basic_symbol.len{
		return new_empty_symbol()
	}

	if c_symbol.end_index < 0 || c_symbol.end_index >= r.all_basic_symbol.len{
		return new_empty_symbol()
	}

	if !(c_symbol.name == '{}fn' || c_symbol.name == '{}pub_fn'){
		return new_empty_symbol()
	}	

	for i:=c_symbol.start_index;i<=c_symbol.end_index;i++{
		b_symbol := r.all_basic_symbol[i]
		if b_symbol.name == 'fn'{
			return r.all_basic_symbol[i+2]
		}
	}
	return new_empty_symbol()
}