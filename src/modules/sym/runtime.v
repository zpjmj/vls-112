module sym

import os

//运行时提供运行时必须的外部环境
[heap]
struct Runtime{
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
		mut undefine_start_word_pos:=0
		mut undefine_start_byte_pos:=0
		mut	start_word_pos:=scanner.word_pos
		mut	start_byte_pos:=scanner.byte_pos

		for{
	next:
			start_word_pos = scanner.word_pos
			start_byte_pos = scanner.byte_pos
			
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
								}
								byte_range:Range{
									start:undefine_start_byte_pos
									end:start_byte_pos
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
							}
							byte_range:Range{
								start:start_byte_pos
								end:scanner.byte_pos
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
									}
									byte_range:Range{
										start:undefine_start_byte_pos
										end:start_byte_pos
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
								}
								byte_range:Range{
									start:start_byte_pos
									end:scanner.byte_pos
								}
								start_index:r.all_basic_symbol.len
							}
							goto next
						}else{
							if undefine_start{
								r.all_basic_symbol << Symbol{
									name:''
									typ:.undefined
									scanner:scanner
									text_range:Range{
										start:undefine_start_word_pos
										end:scanner.word_pos
									}
									byte_range:Range{
										start:undefine_start_byte_pos
										end:scanner.byte_pos
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
									}
									byte_range:Range{
										start:start_byte_pos
										end:scanner.byte_pos
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
						}
						byte_range:Range{
							start:basic_symbol.byte_range.start
							end:next_basic_symbol.byte_range.end
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