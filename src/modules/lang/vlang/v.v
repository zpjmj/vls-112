module vlang

import sym

const (
	all_ws=[byte(32),byte(9),byte(10),byte(11),byte(12),byte(13)]  //空白字符
)

pub fn new_vlang_sym_context() ?sym.Context{
	mut context := sym.new_context()
	mut basic_symbol_priority_level := []string{}
	mut composite_symbol_priority_level := []string{}
	mut sub_composite_symbol_priority_level := []string{}
	mut match_fn_arr := []sym.FuncSymbolBool{}
	mut scope_index_map := map[string][]int{}
	mut parent := []string{}

	define01 := context.new_basic_symbol_define(basic_start_01,basic_end_01,basic_continue_01,false,0,false)
	context.def_basic_symbol('ws',define01)?
	
	define02 := context.new_basic_symbol_define(basic_start_02,basic_end_02,empty_fn_byte,true,6,false)
	context.def_basic_symbol('import',define02)?
	
	define03 := context.new_basic_symbol_define(basic_start_03,basic_end_03,empty_fn_byte,true,3,false)
	context.def_basic_symbol('pub',define03)?
	
	define04 := context.new_basic_symbol_define(basic_start_04,basic_end_04,empty_fn_byte,true,6,false)
	context.def_basic_symbol('struct',define04)?
	
	define05 := context.new_basic_symbol_define(basic_start_05,basic_end_05,empty_fn_byte,true,2,false)
	context.def_basic_symbol('fn',define05)?
	
	define06 := context.new_basic_symbol_define(basic_start_06,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('.',define06)?
	
	define07 := context.new_basic_symbol_define(basic_start_07,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('{',define07)?
	
	define08 := context.new_basic_symbol_define(basic_start_08,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('}',define08)?
	
	define09 := context.new_basic_symbol_define(basic_start_09,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('(',define09)?
	
	define10 := context.new_basic_symbol_define(basic_start_10,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol(')',define10)?
	
	define11 := context.new_basic_symbol_define(basic_start_11,basic_end_11,empty_fn_byte,true,2,false)
	context.def_basic_symbol(':=',define11)?
	
	define12 := context.new_basic_symbol_define(basic_start_12,basic_end_12,empty_fn_byte,true,6,false)
	context.def_basic_symbol('module',define12)?
	
	define13 := context.new_basic_symbol_define(basic_start_13,basic_end_13,basic_continue_13,false,0,false)
	context.def_basic_symbol('name',define13)?

	define14 := context.new_basic_symbol_define(basic_start_14,basic_end_14,basic_continue_14,false,0,true)
	context.def_basic_symbol('comment',define14)?
	
	define15 := context.new_basic_symbol_define(basic_start_15,basic_end_15,basic_continue_15,false,0,true)
	context.def_basic_symbol('string_single_quotes',define15)?

	define16 := context.new_basic_symbol_define(basic_start_16,basic_end_16,basic_continue_16,false,0,true)
	context.def_basic_symbol('string_double_quotes',define16)?

	define17 := context.new_basic_symbol_define(basic_start_17,basic_end_17,empty_fn_byte,true,2,false)
	context.def_basic_symbol('as',define17)?

	define18 := context.new_basic_symbol_define(basic_start_18,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol(',',define18)?

	define19 := context.new_basic_symbol_define(basic_start_19,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol('[',define19)?

	define20 := context.new_basic_symbol_define(basic_start_20,empty_fn_byte2,empty_fn_byte,true,1,false)
	context.def_basic_symbol(']',define20)?

	basic_symbol_priority_level << 'ws'
	basic_symbol_priority_level << 'comment'
	basic_symbol_priority_level << 'module'
	basic_symbol_priority_level << 'import'
	basic_symbol_priority_level << 'pub'
	basic_symbol_priority_level << 'struct'
	basic_symbol_priority_level << 'fn'
	basic_symbol_priority_level << 'as'
	basic_symbol_priority_level << '.'
	basic_symbol_priority_level << ','
	basic_symbol_priority_level << '['
	basic_symbol_priority_level << ']'
	basic_symbol_priority_level << '{'
	basic_symbol_priority_level << '}'
	basic_symbol_priority_level << '('
	basic_symbol_priority_level << ')'
	basic_symbol_priority_level << ':='
	basic_symbol_priority_level << 'name'
	basic_symbol_priority_level << 'string_single_quotes'
	basic_symbol_priority_level << 'string_double_quotes'
	context.basic_symbol_priority_level_push(basic_symbol_priority_level)?

	/*
	* match fn 命名
	* 基本符号名 + _ + flg
	* flg分类 ：0非必须  1必须有一个 2期待一个
	*/
	match_fn_arr=[ws_1,fn_1,ws_1,name_1,ws_0,lpar_1,rpar_2,lcbr_2,rcbr_2_end]
	define_c01 := context.new_composite_symbol_define(composite_start_pub,match_fn_arr)
	context.def_composite_symbol('{}pub_fn',define_c01)?

	match_fn_arr=[ws_1,name_1,ws_0,lpar_1,rpar_2,lcbr_2,rcbr_2_end]
	define_c02 := context.new_composite_symbol_define(composite_start_fn,match_fn_arr)
	context.def_composite_symbol('{}fn',define_c02)?

	match_fn_arr=[ws_1,fn_1,ws_0,lpar_1,rpar_2,ws_0,name_1,ws_0,lpar_1,rpar_2,lcbr_2,rcbr_2_end]
	define_c03 := context.new_composite_symbol_define(composite_start_pub,match_fn_arr)
	context.def_composite_symbol('{}pub_method',define_c03)?

	match_fn_arr=[ws_0,lpar_1,rpar_2,ws_0,name_1,ws_0,lpar_1,rpar_2,lcbr_2,rcbr_2_end]
	define_c04 := context.new_composite_symbol_define(composite_start_fn,match_fn_arr)
	context.def_composite_symbol('{}method',define_c04)?

	match_fn_arr=[ws_1,struct_1,ws_1,name_1,ws_0,lcbr_2,rcbr_2_end]
	define_c05 := context.new_composite_symbol_define(composite_start_pub,match_fn_arr)
	context.def_composite_symbol('{}pub_struct',define_c05)?

	match_fn_arr=[ws_1,name_1,ws_0,lcbr_2,rcbr_2_end]
	define_c06 := context.new_composite_symbol_define(composite_start_struct,match_fn_arr)
	context.def_composite_symbol('{}struct',define_c06)?

	match_fn_arr=[import_molule_continue_01,import_molule_continue_02]
	define_c07 := context.new_composite_symbol_define(composite_start_import,match_fn_arr)
	context.def_composite_symbol('{}import_molule',define_c07)?

	match_fn_arr=[ws_1,name_1,import_molule_continue_02]
	define_c08 := context.new_composite_symbol_define(composite_start_module,match_fn_arr)
	context.def_composite_symbol('{}module_decl',define_c08)?

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
	scope_index_map['{}pub_fn'] = [0,1]
	scope_index_map['{}fn'] = [0,1]
	scope_index_map['{}pub_method'] = [1,2]
	scope_index_map['{}method'] = [1,2]
	scope_index_map['()fn'] = [0]
	match_fn_arr=[fn_dot_0,fn_name_1,ws_0,lpar_1,rpar_2_end]
	define_sc01 := context.new_composite_symbol_define(sub_composite_start_name,match_fn_arr)
	context.def_sub_composite_symbol('()fn',define_sc01,parent,scope_index_map)?

	sub_composite_symbol_priority_level << '()fn'
	context.sub_composite_symbol_priority_level_push(sub_composite_symbol_priority_level)?

	return context
}

//===========================================================================
fn empty_fn_symbol(input sym.Symbol)bool{
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
			if input[input.len -1] == sym.scan_end{
				return false
			}
		}else if input.len > 2{
			if input[input.len -2] == `\n` || input[input.len -1] == sym.scan_end{
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

//as
fn basic_start_17(input []byte)bool{
	return key_com_start(input,`a`)
}
fn basic_end_17(input []byte)bool{
	return key_com_end(input,2,'s')
}

//,
fn basic_start_18(input []byte)bool{
	return key_com_start(input,`,`)
}

//[
fn basic_start_19(input []byte)bool{
	return key_com_start(input,`[`)
}

//]
fn basic_start_20(input []byte)bool{
	return key_com_start(input,`]`)
}







//====================================================================
//pub fn
fn composite_start_pub(input sym.Symbol)bool{
	if input.name == 'pub'{
		return true
	}
	return false
}

//fn
fn composite_start_fn(input sym.Symbol)bool{
	if input.name == 'fn'{
		return true
	}
	return false
}

//struct
fn composite_start_struct(input sym.Symbol)bool{
	if input.name == 'struct'{
		return true
	}
	return false
}

//struct
fn composite_start_import(input sym.Symbol)bool{
	if input.name == 'import'{
		return true
	}
	return false
}

//module
fn composite_start_module(input sym.Symbol)bool{
	if input.name == 'module'{
		return true
	}
	return false
}

//================================================
//composite match common function
fn ws_1(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == 'ws'{
		return true,1,1,0
	}
	return false,0,0,0
}

fn fn_1(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == 'fn'{
		return true,1,1,0
	}
	return false,0,0,0
}

fn struct_1(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == 'struct'{
		return true,1,1,0
	}
	return false,0,0,0
}

fn name_1(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == 'name'{
		return true,1,1,0
	}
	return false,0,0,0
}

fn ws_0(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == 'ws'{
		return true,1,1,0
	}
	return true,0,1,0
}

fn lpar_1(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == '('{
		scope_index_arr << input.start_index
		return true,1,1,1
	}
	return false,0,0,0
}

fn rpar_2(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	mut tmp_tier := tier

	if input.name == '('{
		tmp_tier++
		return true,1,0,tmp_tier
	}

	if input.name == ')'{
		tmp_tier--
		if tmp_tier == 0{
			scope_index_arr << input.start_index
			return true,1,1,0
		}
	}

	return true,1,0,tmp_tier
}

fn lcbr_2(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == '{'{
		scope_index_arr << input.start_index
		return true,1,1,1
	}

	return true,1,0,0
}

fn rcbr_2_end(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	mut tmp_tier := tier

	if input.name == '{'{
		tmp_tier++
		return true,1,0,tmp_tier
	}

	if input.name == '}'{
		tmp_tier--
		if tmp_tier == 0{
			scope_index_arr << input.start_index
			return false,0,0,0
		}
	}

	return true,1,0,tmp_tier
}

fn import_molule_continue_01(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name in ['name','.','as','{','}',',','ws']{
		return true,1,0,0
	}
	return true,-1,1,0
}

fn import_molule_continue_02(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	
	if input.name != 'ws'{
		return true,0,1,0
	}
	
	text:=input.get_text()

	mut flg:= 0

	for i in text{
		if i == `\n`{
			flg++
		}
	}
	
	if flg > 0{
		return false,0,0,0
	}
	
	return true,0,1,0
}

//====================================================================
//()fn
fn sub_composite_start_name(input sym.Symbol)bool{
	if input.name == 'name'{
		return true
	}
	return false
}

fn fn_dot_0(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == '.'{
		return true,1,1,0
	}
	return true,0,2,0
}

fn fn_name_1(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	if input.name == 'name'{
		return true,1,-1,0
	}
	return false,0,0,0
}

fn rpar_2_end(input sym.Symbol,tier int,mut scope_index_arr []int)(bool,int,int,int){
	mut tmp_tier := tier

	if input.name == '('{
		tmp_tier++
		return true,1,0,tmp_tier
	}

	if input.name == ')'{
		tmp_tier--
		if tmp_tier == 0{
			scope_index_arr << input.start_index
			return false,0,0,0
		}
	}

	return true,1,0,tmp_tier
}