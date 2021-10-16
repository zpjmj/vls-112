module main

import symboldb
import os

const (
	all_ws=[byte(32),byte(9),byte(10),byte(11),byte(12),byte(13)]  //空白字符
)

fn print_symbol_type(all_symbol []symboldb.Symbol){
	println('')
	println('====================================================')
	
	for i,s in all_symbol{

		if s.name == ''{
			print('undefined')
		}else{
			print(s.name)
		}	
		print(' ')
		if (i+1)%10 == 0 {
			print('\n')
		} 
	}
	print('\n')
	print('\n')
}


fn main(){
	mut context := symboldb.new_context()
	mut runtime := symboldb.new_runtime(&context)
	mut basic_symbol_priority_level := []string{}
	mut composite_symbol_priority_level := []string{}

	define01 := context.new_basic_symbol_define(basic_start_01,basic_end_01,basic_continue_01,false,0,false)
	context.def_basic_symbol('ws',define01) or {panic(err)}
	
	define02 := context.new_basic_symbol_define(basic_start_02,basic_end_02,empty_fn_byte,true,6,false)
	context.def_basic_symbol('import',define02) or {panic(err)}
	
	define03 := context.new_basic_symbol_define(basic_start_03,basic_end_03,empty_fn_byte,true,3,false)
	context.def_basic_symbol('pub',define03) or {panic(err)}
	
	define04 := context.new_basic_symbol_define(basic_start_04,basic_end_04,empty_fn_byte,true,6,false)
	context.def_basic_symbol('struct',define04) or {panic(err)}
	
	define05 := context.new_basic_symbol_define(basic_start_05,basic_end_05,empty_fn_byte,true,2,false)
	context.def_basic_symbol('fn',define05) or {panic(err)}
	
	define06 := context.new_basic_symbol_define(basic_start_06,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('.',define06) or {panic(err)}
	
	define07 := context.new_basic_symbol_define(basic_start_07,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('{',define07) or {panic(err)}
	
	define08 := context.new_basic_symbol_define(basic_start_08,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('}',define08) or {panic(err)}
	
	define09 := context.new_basic_symbol_define(basic_start_09,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('(',define09) or {panic(err)}
	
	define10 := context.new_basic_symbol_define(basic_start_10,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol(')',define10) or {panic(err)}
	
	define11 := context.new_basic_symbol_define(basic_start_11,basic_end_11,empty_fn_byte,true,2,false)
	context.def_basic_symbol(':=',define11) or {panic(err)}
	
	define12 := context.new_basic_symbol_define(basic_start_12,basic_end_12,empty_fn_byte,true,6,false)
	context.def_basic_symbol('module',define12) or {panic(err)}
	
	define13 := context.new_basic_symbol_define(basic_start_13,basic_end_13,basic_continue_13,false,0,false)
	context.def_basic_symbol('name',define13) or {panic(err)}

	define14 := context.new_basic_symbol_define(basic_start_14,basic_end_14,basic_continue_14,false,0,true)
	context.def_basic_symbol('comment',define14) or {panic(err)}
	
	define15 := context.new_basic_symbol_define(basic_start_15,basic_end_15,basic_continue_15,false,0,true)
	context.def_basic_symbol('string_single_quotes',define15) or {panic(err)}

	define16 := context.new_basic_symbol_define(basic_start_16,basic_end_16,basic_continue_16,false,0,true)
	context.def_basic_symbol('string_double_quotes',define16) or {panic(err)}

	basic_symbol_priority_level << 'ws'
	basic_symbol_priority_level << 'comment'
	basic_symbol_priority_level << 'module'
	basic_symbol_priority_level << 'import'
	basic_symbol_priority_level << 'pub'
	basic_symbol_priority_level << 'struct'
	basic_symbol_priority_level << 'fn'
	basic_symbol_priority_level << '.'
	basic_symbol_priority_level << '{'
	basic_symbol_priority_level << '}'
	basic_symbol_priority_level << '('
	basic_symbol_priority_level << ')'
	basic_symbol_priority_level << ':='
	basic_symbol_priority_level << 'name'
	basic_symbol_priority_level << 'string_single_quotes'
	basic_symbol_priority_level << 'string_double_quotes'
	context.basic_symbol_priority_level_push(basic_symbol_priority_level) or {panic(err)}

	// context.def_composite_symbol('imp module')
	// context.def_composite_symbol('pub Function')
	// context.def_composite_symbol('pub method')
	// context.def_composite_symbol('pub struct')
	// context.def_composite_symbol('fn')
	// context.def_composite_symbol('method')
	// context.def_composite_symbol('struct')
	// context.def_composite_symbol('var decl')

	mut match_fn_arr := []symboldb.FuncSymbolBool{}

	match_fn_arr=[step01_01,step01_02,step01_03,step01_04,step01_05,step01_06,step01_07,step01_08,step01_09]
	define_c01 := context.new_composite_symbol_define(composite_start_01,match_fn_arr)
	context.def_composite_symbol('pub_fn{}',define_c01) or {panic(err)}

	match_fn_arr=[step01_03,step01_04,step01_05,step01_06,step01_07,step01_08,step01_09]
	define_c02 := context.new_composite_symbol_define(composite_start_02,match_fn_arr)
	context.def_composite_symbol('fn{}',define_c02) or {panic(err)}

	match_fn_arr=[step01_01,step01_02,step01_05,step01_06,step01_07,step01_05,step01_04,step01_05,step01_06,step01_07,step01_08,step01_09]
	define_c03 := context.new_composite_symbol_define(composite_start_01,match_fn_arr)
	context.def_composite_symbol('pub_method{}',define_c03) or {panic(err)}

	match_fn_arr=[step01_05,step01_06,step01_07,step01_05,step01_04,step01_05,step01_06,step01_07,step01_08,step01_09]
	define_c04 := context.new_composite_symbol_define(composite_start_02,match_fn_arr)
	context.def_composite_symbol('method{}',define_c04) or {panic(err)}

	composite_symbol_priority_level << 'pub_fn{}'
	composite_symbol_priority_level << 'fn{}'
	composite_symbol_priority_level << 'pub_method{}'
	composite_symbol_priority_level << 'method{}'

	context.composite_symbol_priority_level_push(composite_symbol_priority_level) or {panic(err)}

	runtime.all_file << os.join_path(os.getwd(),'testf.v')
	runtime.parse() or {panic(err)}

	println(runtime.all_symbol)
	print_symbol_type(runtime.all_symbol)
}

fn empty_fn_symbol(input symboldb.Symbol)bool{
	return false
}
fn empty_fn_byte(input []byte)bool{
	return false
}
fn empty_fn_byte2(input []byte)bool{
	return true
}

fn key_com_start(input []byte,key byte)bool{
	if input.len > 0{
		if input[0] == key{
			return true
		}
	}
	return false
}
fn key_com_end(input []byte,len int,match_str string)bool{
	if input.len == len{
		for i,s in match_str{
			if input[i] != s{
				return false
			} 
		}

		end_byte := input[input.len - 1]

		if (end_byte > 0x2f && end_byte < 0x3a) || 
		   (end_byte > 0x40 && end_byte < 0x5b) || 
		   (end_byte > 0x60 && end_byte < 0x7b) || 
		   (end_byte == 0x5f){
			return false
		}

		return true
	}
	return false
}


//ws
fn basic_start_01(input []byte)bool{
	for i in input{
		if i !in all_ws{
			return false
		}
	}
	return true
}
fn basic_end_01(input []byte)bool{
	return true
}
fn basic_continue_01(input []byte)bool{
	for i in input{
		if i !in all_ws{
			return false
		}
	}
	return true
}

//import
fn basic_start_02(input []byte)bool{
	return key_com_start(input,`i`)
}
fn basic_end_02(input []byte)bool{
	return key_com_end(input,6,'mport')
}

//pub
fn basic_start_03(input []byte)bool{
	return key_com_start(input,`p`)
}
fn basic_end_03(input []byte)bool{
	return key_com_end(input,3,'ub')
}

//struct
fn basic_start_04(input []byte)bool{
	return key_com_start(input,`s`)
}
fn basic_end_04(input []byte)bool{
	return key_com_end(input,6,'truct')
}

//fn
fn basic_start_05(input []byte)bool{
	return key_com_start(input,`f`)
}
fn basic_end_05(input []byte)bool{
	return key_com_end(input,2,'n')
}

//.
fn basic_start_06(input []byte)bool{
	return key_com_start(input,`.`)
}

//{
fn basic_start_07(input []byte)bool{
	return key_com_start(input,`{`)
}

//}
fn basic_start_08(input []byte)bool{
	return key_com_start(input,`}`)
}

//(
fn basic_start_09(input []byte)bool{
	return key_com_start(input,`(`)
}

//)
fn basic_start_10(input []byte)bool{
	return key_com_start(input,`)`)
}

//:=
fn basic_start_11(input []byte)bool{
	return key_com_start(input,`:`)
}
fn basic_end_11(input []byte)bool{
	return key_com_end(input,2,'=')
}

//module
fn basic_start_12(input []byte)bool{
	return key_com_start(input,`m`)
}
fn basic_end_12(input []byte)bool{
	return key_com_end(input,6,'odule')
}

//name
fn basic_start_13(input []byte)bool{
	for i in input{
		if !((i > 0x40 && i < 0x5b) || (i > 0x60 && i < 0x7b)) {
			return false
		}
	}
	return true
}
fn basic_end_13(input []byte)bool{
	return true
}
fn basic_continue_13(input []byte)bool{
	for i in input{
		if !((i > 0x2f && i < 0x3a) || 
		   (i > 0x40 && i < 0x5b) || 
		   (i > 0x60 && i < 0x7b) || 
		   (i == 0x5f)){
			return false
		}
	}
	return true
}

//comment
fn basic_start_14(input []byte)bool{
	for i in input{
		if i != `/` {
			return false
		}
	}
	return true
}
fn basic_end_14(input []byte)bool{
	return !basic_continue_end_14_com(input,true)
}
fn basic_continue_14(input []byte)bool{
	return basic_continue_end_14_com(input,false)
}

fn basic_continue_end_14_com(input []byte,flg bool)bool{
	if input[0] == `/`{
		if input.len == 2{
			if input[input.len -1] == symboldb.scan_end{
				return false
			}
		}else if input.len > 2{
			if input[input.len -2] == `\n` || input[input.len -1] == symboldb.scan_end{
				return false
			}
		}
		return true
	}else if input[0] == `*`{
		if input.len >= 4{
			if input[input.len -2] == `/` && input[input.len -3] == `*`{
				mut left_num := 1
				mut right_num := 0

				for i := 1;i<input.len;i++{
					first_byte := input[i]
					mut second_byte := byte(0b0)
					if i+1 < input.len{
						second_byte = input[i+1]
					}

					if first_byte == `/` && second_byte == `*`{
						left_num++
						i++
					}else if first_byte == `*` && second_byte == `/`{
						right_num++
						i++
					}
				}

				if left_num == right_num{
					return false
				}
				return true
			}
		}
		return true
	}

	return flg
}

//string
fn basic_continue_string_com(input []byte,quotes byte)bool{
	if input.len > 1{
		if input[input.len -2] == quotes{
			if input.len > 2{
				prev_byte:=input[input.len -3]
				if prev_byte == `\\`{
					mut backslash_num :=0

					for i:=input.len - 3;i>=0;i--{
						if input[i] == `\\`{
							backslash_num++
						}else{
							break
						}
					}

					if backslash_num%2 != 0{
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
//string_single_quotes
fn basic_start_15(input []byte)bool{
	for i in input{
		if i != `'` {
			return false
		}
	}
	return true
}
fn basic_end_15(input []byte)bool{
	return !basic_continue_string_com(input,`'`)
}
fn basic_continue_15(input []byte)bool{
	return basic_continue_string_com(input,`'`)
}

//string_double_quotes
fn basic_start_16(input []byte)bool{
	for i in input{
		if i != `"` {
			return false
		}
	}
	return true
}
fn basic_end_16(input []byte)bool{
	return !basic_continue_string_com(input,`"`)
}
fn basic_continue_16(input []byte)bool{
	return basic_continue_string_com(input,`"`)
}

//====================================================================
//pub fn
fn composite_start_01(input symboldb.Symbol)bool{
	if input.name == 'pub'{
		return true
	}
	return false
}

fn step01_01(input symboldb.Symbol,tier int)(bool,int,int,int){
	if input.name == 'ws'{
		return true,1,1,0
	}
	return false,0,0,0
}

fn step01_02(input symboldb.Symbol,tier int)(bool,int,int,int){
	if input.name == 'fn'{
		return true,1,1,0
	}
	return false,0,0,0
}

fn step01_03(input symboldb.Symbol,tier int)(bool,int,int,int){
	if input.name == 'ws'{
		return true,1,1,0
	}
	return false,0,0,0
}

fn step01_04(input symboldb.Symbol,tier int)(bool,int,int,int){
	if input.name == 'name'{
		return true,1,1,0
	}
	return false,0,0,0
}

fn step01_05(input symboldb.Symbol,tier int)(bool,int,int,int){
	if input.name == 'ws'{
		return true,1,1,0
	}
	return true,0,1,0
}

fn step01_06(input symboldb.Symbol,tier int)(bool,int,int,int){
	if input.name == '('{
		return true,1,1,1
	}
	return false,0,0,0
}

fn step01_07(input symboldb.Symbol,tier int)(bool,int,int,int){
	mut tmp_tier := tier

	if input.name == '('{
		return true,1,0,tmp_tier++
	}

	if input.name == ')'{
		tmp_tier--
		if tmp_tier == 0{
			return true,1,1,0
		}
	}

	return true,1,0,tmp_tier
}

fn step01_08(input symboldb.Symbol,tier int)(bool,int,int,int){
	if input.name == '{'{
		return true,1,1,1
	}

	return true,1,0,0
}

fn step01_09(input symboldb.Symbol,tier int)(bool,int,int,int){
	mut tmp_tier := tier

	if input.name == '{'{
		return true,1,0,tmp_tier++
	}

	if input.name == '}'{
		tmp_tier--
		if tmp_tier == 0{
			return false,0,0,0
		}
	}

	return true,1,0,tmp_tier
}

//fn
fn composite_start_02(input symboldb.Symbol)bool{
	if input.name == 'fn'{
		return true
	}
	return false
}