module server

import sym
import os
import crypto.sha1
import lsp
import lang.vlang
import toml

import v.pref
import v.builder
import v.util

struct Symboldb{
mut:
	file_symbol_cache map[string]&FileSymbol
	now_file string
	prefs &pref.Preferences
	vbuilder builder.Builder
}

struct FileSymbol{
mut:
	//文件哈希值
	hexhash string
	context sym.Context
	runtime sym.Runtime
	//文件统计信息
	//文件的模块名 缺省时为main
	module_name string
	//所有引入的外部模块和全名 ex:import aa.bb.cc = cc:['aa','bb','cc']
	import_module map[string][]string
	//其他模块引入的全局函数和结构体 ex:import aa.ff as tt{f1,f2} = f1:'tt',f2:'tt'
	all_other_module_global map[string]string
	//本文件包含的全部内部函数
	all_fn map[string]sym.Symbol
	//本文件包含的全部公共函数
	all_pub_fn map[string]sym.Symbol
}

struct DfLocationLink{
	is_found bool
	uri string
	target_range lsp.Range
	target_selection_range lsp.Range
	origin_selection_range lsp.Range
}

fn new_symboldb(root_path string,vexe string)Symboldb{
	mut main_f := root_path
	vls_112_toml := os.join_path(root_path,'vls-112.toml')
	if os.is_file(vls_112_toml){
		for{
			doc := toml.parse_file(vls_112_toml) or {break}
			mut tmp_main_f := doc.value('symboldb.main').string()
			if !os.is_abs_path(tmp_main_f){
				tmp_main_f = os.join_path(root_path,tmp_main_f)
			}

			if os.is_file(tmp_main_f){
				main_f = tmp_main_f
			}
			break
		}
	}
	
	os.setenv('VEXE', vexe, true)
	//初始化v pref
	mut args_and_flags := [main_f]
	v_env_args := util.join_env_vflags_and_os_args()
	for args_i := os.args.len;args_i<v_env_args.len;args_i++{
		args_and_flags << v_env_args[args_i]
	}
	mut prefs,_ := pref.parse_args([]string{}, args_and_flags)
	prefs.is_verbose = false
	mut vbuilder := builder.new_builder(prefs)
	set_module_lookup_paths(mut vbuilder,prefs)

	return Symboldb{
		prefs:prefs
		vbuilder:vbuilder
	}
}

//模拟 v源码 Builder.set_module_lookup_paths
fn set_module_lookup_paths(mut vbuilder builder.Builder,prefs &pref.Preferences) {
	vbuilder.module_search_paths = []
	if prefs.is_test {
		vbuilder.module_search_paths << os.dir(vbuilder.compiled_dir) // pdir of _test.v
	}
	vbuilder.module_search_paths << vbuilder.compiled_dir
	vbuilder.module_search_paths << os.join_path(vbuilder.compiled_dir, 'modules')
	vbuilder.module_search_paths << prefs.lookup_path
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
			file_symbol.hexhash = hexhash
			// unsafe{
			// 	file_symbol.runtime.all_basic_symbol.free()
			// 	file_symbol.runtime.all_composite_symbol.free()
			// 	file_symbol.import_module.free()
			// 	file_symbol.all_other_module_global.free()
			// 	file_symbol.all_fn.free()
			// 	file_symbol.all_pub_fn.free()
			// }
			file_symbol.runtime.all_basic_symbol = []sym.Symbol{}
			file_symbol.runtime.all_composite_symbol = []sym.Symbol{}
			file_symbol.module_name = ''
			file_symbol.import_module = map[string][]string{}
			file_symbol.all_other_module_global = map[string]string{}
			file_symbol.all_fn = map[string]sym.Symbol{}
			file_symbol.all_pub_fn = map[string]sym.Symbol{}

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

	//module name
	mut main_module_flg := true
	mut once_flg:=true

	for c_symbol in file_symbol.runtime.all_composite_symbol{
		if c_symbol.name == '{}fn' || c_symbol.name == '{}pub_fn'{
			fn_name := file_symbol.runtime.get_fn_name(c_symbol)
			if fn_name != ''{
				match c_symbol.name{
					'{}fn'{
						if fn_name !in file_symbol.all_fn{
							file_symbol.all_fn[fn_name] = c_symbol
						}	
					}
					'{}pub_fn'{
						if fn_name !in file_symbol.all_pub_fn{
							file_symbol.all_pub_fn[fn_name] = c_symbol
						}	
					}
					else{
						continue
					}
				}			
			}
			continue
		}

		if c_symbol.name == '{}import_molule'{
			mut err_flg := false
			mut abs_module_name := []string{}
			mut other_module_global := []string{}
			mut abs_module_flg := true
			mut module_name := ''
			mut as_flg := false
			mut lcbr_flg := false
			mut prev_b_symbol := sym.new_empty_symbol()
			mut b_symbol := sym.new_empty_symbol()
			mut next_b_symbol := sym.new_empty_symbol()

			for i:=c_symbol.start_index + 2;i<=c_symbol.end_index;i++{
				prev_b_symbol = file_symbol.runtime.all_basic_symbol[i-1]
				b_symbol = file_symbol.runtime.all_basic_symbol[i]
				if i + 1 >= file_symbol.runtime.all_basic_symbol.len{
					next_b_symbol = file_symbol.runtime.all_basic_symbol[file_symbol.runtime.all_basic_symbol.len - 1]
				}else{
					next_b_symbol = file_symbol.runtime.all_basic_symbol[i+1]
				}

				if abs_module_flg{
					if b_symbol.name == 'name'{
						module_name = b_symbol.get_text()
						abs_module_name << module_name
						continue
					}
					if b_symbol.name == '.'{
						if prev_b_symbol.name != 'name' || next_b_symbol.name != 'name'{
							err_flg = true
							break
						}
						continue
					}
					if b_symbol.name == 'ws'{
						if i == c_symbol.end_index {
							break
						}
						if next_b_symbol.name == 'as'{
							i++
							as_flg = true
							abs_module_flg = false
							continue
						}
						if next_b_symbol.name == '{'{
							i++
							lcbr_flg = true
							abs_module_flg = false
							continue
						}
						err_flg = true
						break
					}
					err_flg = true
					break
				}

				if as_flg{
					if b_symbol.name != 'ws' || next_b_symbol.name != 'name'{
						err_flg = true
						break
					}
					module_name = next_b_symbol.get_text()

					i = i + 2
					if i == c_symbol.end_index {
						break
					}

					if i >= file_symbol.runtime.all_basic_symbol.len{
						if i - 1 >= file_symbol.runtime.all_basic_symbol.len{
							prev_b_symbol = file_symbol.runtime.all_basic_symbol[file_symbol.runtime.all_basic_symbol.len - 1]
						}else{
							prev_b_symbol = file_symbol.runtime.all_basic_symbol[i-1]
						}
						b_symbol = file_symbol.runtime.all_basic_symbol[file_symbol.runtime.all_basic_symbol.len - 1]
						next_b_symbol = file_symbol.runtime.all_basic_symbol[file_symbol.runtime.all_basic_symbol.len - 1]
					}else{
						prev_b_symbol = file_symbol.runtime.all_basic_symbol[i-1]
						b_symbol = file_symbol.runtime.all_basic_symbol[i]
						if i + 1 >= file_symbol.runtime.all_basic_symbol.len{
							next_b_symbol = file_symbol.runtime.all_basic_symbol[file_symbol.runtime.all_basic_symbol.len - 1]
						}else{
							next_b_symbol = file_symbol.runtime.all_basic_symbol[i+1]
						}
					}

					if b_symbol.name == '{'{
						as_flg=false
						lcbr_flg=true
						continue
					}

					if b_symbol.name == 'ws' || next_b_symbol.name == '{'{
						i++
						as_flg=false
						lcbr_flg=true
						continue
					}
					err_flg = true
				}

				if lcbr_flg{
					if b_symbol.name == 'ws'{
						if i == c_symbol.end_index {
							err_flg = true
							break
						}
						if prev_b_symbol.name == '{' && next_b_symbol.name == 'name'{
							continue
						}

						if prev_b_symbol.name == 'name' && next_b_symbol.name == ','{
							continue
						}

						if prev_b_symbol.name == ',' && next_b_symbol.name == 'name'{
							continue
						}

						if prev_b_symbol.name == 'name' && next_b_symbol.name == '}'{
							continue
						}						
						err_flg = true
						break
					}
					if b_symbol.name == 'name'{
						other_module_global << b_symbol.get_text()
						continue
					}
					if b_symbol.name == ','{
						if prev_b_symbol.name == 'name' && next_b_symbol.name == 'name'{
							continue
						}
						if prev_b_symbol.name == 'ws' && next_b_symbol.name == 'ws'{
							continue
						}						
						if prev_b_symbol.name == 'ws' && next_b_symbol.name == 'name'{
							continue
						}		
						if prev_b_symbol.name == 'name' && next_b_symbol.name == 'ws'{
							continue
						}		
						err_flg = true
						break
					}
					if b_symbol.name  == '}'{
						if i + 1 == c_symbol.end_index {
							break
						}
						err_flg = true
						break
					}
					err_flg = true
					break
				}
			}

			if err_flg{
				continue
			}

			if module_name in file_symbol.import_module {
				continue
			}

			for j in other_module_global{
				if j in file_symbol.all_other_module_global{
					continue
				}
			}

			file_symbol.import_module[module_name] = abs_module_name
			//全局函数和结构体存储
			for k in other_module_global{
				file_symbol.all_other_module_global[k] = module_name
			}
			continue
		}

		if c_symbol.name == '{}module_decl' && once_flg{
			file_symbol.module_name = file_symbol.runtime.all_basic_symbol[c_symbol.start_index + 2].get_text()
			main_module_flg = false
			once_flg = false
			continue
		}
	}

	if main_module_flg{
		file_symbol.module_name = 'main'
	}

	//debug -----------------------------------------------
	ls.logger.info('file_symbol-->',3)?
	ls.logger.text(file_symbol.runtime.basic_symbol_type_str(),3,'\t')?
	ls.logger.text(file_symbol.runtime.composite_symbol_type_str(),3,'\t')?
	ls.logger.text('-------------------->',3,'\t')?
	ls.logger.info('module_name-->',3)?
	ls.logger.text(file_symbol.module_name.str(),3,'\t')?
	ls.logger.info('import_module-->',3)?
	ls.logger.text(file_symbol.import_module.str(),3,'\t')?
	ls.logger.info('all_other_module_global-->',3)?
	ls.logger.text(file_symbol.all_other_module_global.str(),3,'\t')?

	mut k_arr:=[]string{}
	for k,_ in file_symbol.all_fn{
		k_arr << k
	}

	ls.logger.info('all_fn-->',3)?
	ls.logger.text(k_arr,3,'\t')?
	ls.logger.text(file_symbol.all_fn,3,'\t')?

	k_arr=[]string{}
	for k,_ in file_symbol.all_pub_fn{
		k_arr << k
	}
	ls.logger.info('all_pub_fn-->',3)?
	ls.logger.text(k_arr,3,'\t')?
	ls.logger.text(file_symbol.all_pub_fn,3,'\t')?

	ls.logger.text(file_symbol.runtime.all_composite_symbol,3,'\t')?
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
				for i:=c_symbol.start_index;i<=c_symbol.end_index;i++{
					b_symbol:=file_symbol.runtime.all_basic_symbol[i]	
					if b_symbol.name == 'name'{
						if b_symbol.text_range.start_line == line && 
						   character >= b_symbol.text_range.start_character &&
						   character <= b_symbol.text_range.end_character {
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
				if is_found{
					break
				}else{
					unsafe{name_arr.free()}
					name_arr = []sym.Symbol{}
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
		if fn_name in file_symbol.all_other_module_global{
			return symdb.find_other_module_df_locationlink(mut ls,fn_name,file_symbol.all_other_module_global[fn_name],fn_name_sym)
		}
		return symdb.find_own_module_df_locationlink(mut ls,fn_name,fn_name_sym)
	}

	module_name := name_arr[name_arr.len - 1].get_text()
	if module_name in file_symbol.import_module{
		return symdb.find_other_module_df_locationlink(mut ls,fn_name,module_name,fn_name_sym)
	}

	return DfLocationLink{
		is_found:false
	}
}

fn (mut symdb Symboldb) find_own_module_df_locationlink(mut ls Vls112,fn_name string,fn_name_sym sym.Symbol)?DfLocationLink{
	own_file_symbol := symdb.file_symbol_cache[symdb.now_file]
	//是否为外部引用的全局函数
	if fn_name in own_file_symbol.all_other_module_global{
		module_name := own_file_symbol.all_other_module_global[fn_name]
		return symdb.find_other_module_df_locationlink(mut ls,fn_name,module_name,fn_name_sym)
	}

	ls.logger.info('find_own_module_df_locationlink-->',2)?
	ls.logger.text('function_name: `$fn_name`',2,'\t')?

	if fn_name in own_file_symbol.all_fn{
		c_symbol := own_file_symbol.all_fn[fn_name]
		df_fn_symbol := own_file_symbol.runtime.get_fn_symbol(c_symbol)

		if df_fn_symbol.name == 'name'{
			return DfLocationLink{
				is_found:true
				uri:lsp.document_uri_from_path(symdb.now_file)
				target_range:new_range(c_symbol.text_range.start_line,
										c_symbol.text_range.start_character,
										c_symbol.text_range.end_line,
										c_symbol.text_range.end_character)
				target_selection_range:new_range(df_fn_symbol.text_range.start_line,
										df_fn_symbol.text_range.start_character,
										df_fn_symbol.text_range.end_line,
										df_fn_symbol.text_range.end_character)
				origin_selection_range:new_range(fn_name_sym.text_range.start_line,
										fn_name_sym.text_range.start_character,
										fn_name_sym.text_range.end_line,
										fn_name_sym.text_range.end_character)
			}
		}
	}

	if fn_name in own_file_symbol.all_pub_fn{
		c_symbol := own_file_symbol.all_pub_fn[fn_name]
		df_fn_symbol := own_file_symbol.runtime.get_fn_symbol(c_symbol)

		if df_fn_symbol.name == 'name'{
			return DfLocationLink{
				is_found:true
				uri:lsp.document_uri_from_path(symdb.now_file)
				target_range:new_range(c_symbol.text_range.start_line,
										c_symbol.text_range.start_character,
										c_symbol.text_range.end_line,
										c_symbol.text_range.end_character)
				target_selection_range:new_range(df_fn_symbol.text_range.start_line,
										df_fn_symbol.text_range.start_character,
										df_fn_symbol.text_range.end_line,
										df_fn_symbol.text_range.end_character)
				origin_selection_range:new_range(fn_name_sym.text_range.start_line,
										fn_name_sym.text_range.start_character,
										fn_name_sym.text_range.end_line,
										fn_name_sym.text_range.end_character)
			}
		}
	}

	now_file := symdb.now_file
	own_module_files := symdb.get_own_modele_files()?

	// ls.logger.info(own_module_files.str(),2)?
	// ls.logger.info(now_file,2)?

	for fpath in own_module_files{
		if fpath != now_file{
			symdb.parse(mut ls,fpath)?	
			other_file_symbol := symdb.file_symbol_cache[symdb.now_file]
			if fn_name in other_file_symbol.all_fn{
				c_symbol := other_file_symbol.all_fn[fn_name]
				df_fn_symbol := other_file_symbol.runtime.get_fn_symbol(c_symbol)

				if df_fn_symbol.name == 'name'{
					return DfLocationLink{
						is_found:true
						uri:lsp.document_uri_from_path(symdb.now_file)
						target_range:new_range(c_symbol.text_range.start_line,
												c_symbol.text_range.start_character,
												c_symbol.text_range.end_line,
												c_symbol.text_range.end_character)
						target_selection_range:new_range(df_fn_symbol.text_range.start_line,
												df_fn_symbol.text_range.start_character,
												df_fn_symbol.text_range.end_line,
												df_fn_symbol.text_range.end_character)
						origin_selection_range:new_range(fn_name_sym.text_range.start_line,
												fn_name_sym.text_range.start_character,
												fn_name_sym.text_range.end_line,
												fn_name_sym.text_range.end_character)
					}
				}
			}

			if fn_name in other_file_symbol.all_pub_fn{
				c_symbol := other_file_symbol.all_pub_fn[fn_name]
				df_fn_symbol := other_file_symbol.runtime.get_fn_symbol(c_symbol)

				if df_fn_symbol.name == 'name'{
					return DfLocationLink{
						is_found:true
						uri:lsp.document_uri_from_path(symdb.now_file)
						target_range:new_range(c_symbol.text_range.start_line,
												c_symbol.text_range.start_character,
												c_symbol.text_range.end_line,
												c_symbol.text_range.end_character)
						target_selection_range:new_range(df_fn_symbol.text_range.start_line,
												df_fn_symbol.text_range.start_character,
												df_fn_symbol.text_range.end_line,
												df_fn_symbol.text_range.end_character)
						origin_selection_range:new_range(fn_name_sym.text_range.start_line,
												fn_name_sym.text_range.start_character,
												fn_name_sym.text_range.end_line,
												fn_name_sym.text_range.end_character)
					}
				}
			}
		}
	}


	//path := symdb.vbuilder.find_module_path('os', symdb.now_file) or {'zzzzzzzfffff'}
	// path := symdb.vbuilder.find_module_path('os', symdb.now_file)?

	// //ls.logger.text(os.args,2,'\t')?
	// // mut files := b.get_builtin_files()
	// ls.logger.info('zzzzzzzzzzzzzzzzzzz',2)?
	// // files := symdb.vbuilder.get_user_files()
	// // ls.logger.info(files.str(),2)?
    // //b.find_module_path(mod, ast_file.path)
	// ls.logger.info(path,2)?

	return DfLocationLink{
		is_found:false
	}
}

fn (mut symdb Symboldb) get_own_modele_files()?[]string{
	module_dir := os.dir(symdb.now_file)
	files := os.ls(module_dir)?
	return symdb.prefs.should_compile_filtered_files(module_dir, files)
}

fn (mut symdb Symboldb) find_other_module_df_locationlink(mut ls Vls112,fn_name string,module_name string,fn_name_sym sym.Symbol)?DfLocationLink{
	
	ls.logger.info('find_other_module_df_locationlink-->',2)?
	ls.logger.text('module_name:`$module_name`  function_name:`$fn_name`',2,'\t')?

	module_dir := symdb.vbuilder.find_module_path(module_name, symdb.now_file) or {''}

	if module_dir == ''{
		return DfLocationLink{
			is_found:false
		}
	}

	module_dir_files := os.ls(module_dir)?
	other_module_files := symdb.prefs.should_compile_filtered_files(module_dir, module_dir_files)

	for fpath in other_module_files{
		symdb.parse(mut ls,fpath)?	
		other_file_symbol := symdb.file_symbol_cache[symdb.now_file]

		if other_file_symbol.module_name != module_name{
			continue
		}

		if fn_name in other_file_symbol.all_pub_fn{
			c_symbol := other_file_symbol.all_pub_fn[fn_name]
			df_fn_symbol := other_file_symbol.runtime.get_fn_symbol(c_symbol)

			if df_fn_symbol.name == 'name'{
				return DfLocationLink{
					is_found:true
					uri:lsp.document_uri_from_path(symdb.now_file)
					target_range:new_range(c_symbol.text_range.start_line,
											c_symbol.text_range.start_character,
											c_symbol.text_range.end_line,
											c_symbol.text_range.end_character)
					target_selection_range:new_range(df_fn_symbol.text_range.start_line,
											df_fn_symbol.text_range.start_character,
											df_fn_symbol.text_range.end_line,
											df_fn_symbol.text_range.end_character)
					origin_selection_range:new_range(fn_name_sym.text_range.start_line,
											fn_name_sym.text_range.start_character,
											fn_name_sym.text_range.end_line,
											fn_name_sym.text_range.end_character)
				}
			}
		}
	}

	return DfLocationLink{
		is_found:false
	}
}


