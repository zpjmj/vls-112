module server

import sym
import os
import crypto.sha1
import lsp
import lang.vlang

struct Symboldb{
mut:
	file_symbol_cache map[string]&FileSymbol
	now_file string
}

struct FileSymbol{
mut:
	//文件哈希值
	hexhash string
	context sym.Context
	runtime sym.Runtime
	//文件统计信息
	module_name string
	import_module map[string]bool
	//其他模块引入的全局函数
	all_module_fn map[string]string
	//本文件包含的全部内部函数
	all_fn map[string]&sym.Symbol
	//本文件包含的全部公共函数
	all_pub_fn map[string]&sym.Symbol
}

struct DfLocationLink{
	is_found bool
	uri string
	target_range lsp.Range
	target_selection_range lsp.Range
	origin_selection_range lsp.Range
}

fn new_symboldb()Symboldb{
	return Symboldb{}
}

fn (mut symdb Symboldb) parse(mut ls Vls112,file_path string)?{

	if !os.is_file(file_path){
		return
	}

	hexhash:=sha1.hexhash(os.read_file(file_path)?)
	mut file_symbol := &FileSymbol{}

	if file_path in symdb.file_symbol_cache{
		file_symbol = symdb.file_symbol_cache[file_path]

		if file_symbol.hexhash != hexhash{
			unsafe{
				file_symbol.runtime.all_basic_symbol.free()
				file_symbol.runtime.all_composite_symbol.free()
			}
			file_symbol.runtime.all_basic_symbol = []sym.Symbol{}
			file_symbol.runtime.all_composite_symbol = []sym.Symbol{}
			
			file_symbol.runtime.parse_basic_symbol()?
			file_symbol.runtime.parse_composite_symbol()?
			file_symbol.runtime.parse_sub_composite_symbol()?
		}
	}else{
		context:=vlang.new_vlang_sym_context()?
		mut runtime:=sym.new_runtime(&context)
		runtime.file_path = file_path
		runtime.parse_basic_symbol()?
		runtime.parse_composite_symbol()?
		runtime.parse_sub_composite_symbol()?

        file_symbol=&FileSymbol{
			hexhash:hexhash
			context:context
			runtime:runtime
		}

		symdb.file_symbol_cache[file_path] = file_symbol
	}

	symdb.now_file = file_path
}

fn new_range(start_line int,start_character int,end_line int,end_character int)lsp.Range{
	return lsp.Range{
		start: lsp.Position{
			line:start_line
			character:start_character
		}
		end: lsp.Position{
			line:end_line
			character:end_character
		}
	}
}

//在文件中搜索指定符号
fn (mut symdb Symboldb) search_df_locationlink(mut ls Vls112,line int,character int)?DfLocationLink{
	if symdb.now_file == ''{
		return error('No file to search symbol,please Execute the Symboldb.parse(file_path) first.')
	}
	file_symbol := symdb.file_symbol_cache[symdb.now_file]
	mut is_found := false
	mut is_fn := false
	mut name_arr := []sym.Symbol{}
	mut fn_name_sym := sym.new_empty_symbol()

	for c_symbol in file_symbol.runtime.all_composite_symbol{
		if c_symbol.name != '()fn'{
			continue
		}

		if c_symbol.text_range.start_line == line{
			if character >= c_symbol.text_range.start_character && (character < c_symbol.text_range.end_character || line < c_symbol.text_range.end_line ){
				for i:=c_symbol.start_index;i<c_symbol.end_index;i++{
					b_symbol:=file_symbol.runtime.all_basic_symbol[i]	
					if b_symbol.name == 'name'{
						if b_symbol.text_range.start_line == line && 
						   character >= b_symbol.text_range.start_character &&
						   character < b_symbol.text_range.end_character {
							//is_found = true
							if file_symbol.runtime.all_basic_symbol[i+1].name != '.'{
								
								is_found = true
								is_fn = true
								fn_name_sym = b_symbol
								break
							}
						}
						name_arr << b_symbol
					}
				}
				unsafe{name_arr.free()}
				name_arr = []sym.Symbol{}
				if is_found{
					break
				}
			}
		}
	}

	if !(is_found && is_fn){
		return DfLocationLink{
			is_found:false
		}
	}

	fn_name := fn_name_sym.get_text()

	if name_arr.len == 0{
		if fn_name in file_symbol.all_module_fn{
			return symdb.find_other_module_df_locationlink(mut ls,fn_name,file_symbol.all_module_fn[fn_name])
		}
		return symdb.find_own_module_df_locationlink(mut ls,fn_name)
	}

	module_name := name_arr[name_arr.len - 1].get_text()
	if module_name in file_symbol.import_module{
		return symdb.find_other_module_df_locationlink(mut ls,fn_name,module_name)
	}

	return DfLocationLink{
		is_found:false
	}
}

fn (mut symdb Symboldb) find_own_module_df_locationlink(mut ls Vls112,fn_name string)?DfLocationLink{

	ls.logger.info('find_own_module_df_locationlink-->',2)?
	ls.logger.text(fn_name,2,'\t')?

	return DfLocationLink{
		is_found:false
	}
}

fn (mut symdb Symboldb) find_other_module_df_locationlink(mut ls Vls112,fn_name string,module_name string)?DfLocationLink{
	
	ls.logger.info('find_other_module_df_locationlink-->',2)?

	return DfLocationLink{
		is_found:false
	}
}


