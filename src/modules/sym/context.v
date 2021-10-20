module sym

struct SymbolIndex{
	typ Symboltype
	index int
}

//上下文提供内部定义变量
[heap]
pub struct Context{
mut:
	//保存所有基本符号定义
	all_basic_symbol []BasicSymbol
	//保存所有组合符号定义
	all_composite_symbol []CompositeSymbol
	//保存所有子组合符号定义
	all_sub_composite_symbol []SubCompositeSymbol	
	//保存符号名与定义数组索引的映射
	symbol_map map[string]SymbolIndex
	//基本符号优先级
	basic_symbol_priority_level []int
	//组合符号优先级
	composite_symbol_priority_level []int
	//子组合符号优先级
	sub_composite_symbol_priority_level []int
}

//构造函数
pub fn new_context() Context{
	return Context{}
}

//创建基本符号匹配规则
pub fn (c Context) new_basic_symbol_define(start_func FuncByteBool,end_func FuncByteBool,continue_func FuncByteBool,is_fixed_length bool,len int,continue_fn_input_all bool,on_error_skip bool)BasicSymbolDefine{
	return BasicSymbolDefine{
		is_start:start_func
		is_fixed_length:is_fixed_length
		len:len
		is_continue:continue_func
		is_end:end_func
		continue_fn_input_all:continue_fn_input_all
		on_error_skip:on_error_skip
	}
}

//定义基本符号
pub fn (mut c Context) def_basic_symbol(name string,define BasicSymbolDefine)?{
	if name in c.symbol_map{
		return error('The symbol `$name` is already defined.')
	}

	basic_symbol:=BasicSymbol{
		name:name
		define:define
	}

	c.all_basic_symbol << basic_symbol
	c.symbol_map[name] = SymbolIndex{
		typ:.basic
		index:c.all_basic_symbol.len - 1
	}
}

//创建组合符号匹配规则
pub fn (c Context) new_composite_symbol_define(start_func fn(Symbol)bool,match_func_arr []FuncSymbolBool)CompositeSymbolDefine{
	mut match_func_arr_t := []FuncSymbolBool{}
	match_func_arr_t << match_func_arr

	return CompositeSymbolDefine{
		is_start:start_func
		can_continue:match_func_arr_t[0]
		match_fn_index:0
		match_fn_arr:match_func_arr_t
	}
}

//定义组合符号
pub fn (mut c Context) def_composite_symbol(name string,define CompositeSymbolDefine)?{
	if name in c.symbol_map{
		return error('The symbol `$name` is already defined.')
	}

	composite_symbol:=CompositeSymbol{
		name:name
		define:define
	}

	c.all_composite_symbol << composite_symbol
	c.symbol_map[name] = SymbolIndex{
		typ:.composite
		index:c.all_composite_symbol.len - 1
	}
}

//定义子组合符号
pub fn (mut c Context) def_sub_composite_symbol(name string,define CompositeSymbolDefine,parent []string,scope_index map[string][]int)?{
	if name in c.symbol_map{
		return error('The symbol `$name` is already defined.')
	}

	composite_symbol:=CompositeSymbol{
		name:name
		define:define
	}

	sub_composite_symbol:=SubCompositeSymbol{
		composite_symbol:composite_symbol
		parent:parent
		scope_index:scope_index
	}

	c.all_sub_composite_symbol << sub_composite_symbol
	c.symbol_map[name] = SymbolIndex{
		typ:.sub_composite
		index:c.all_sub_composite_symbol.len - 1
	}
}

//定义符号优先级
pub fn (mut c Context) basic_symbol_priority_level_push(symbol_name_arr []string)?{
	for name in symbol_name_arr{
		if name !in c.symbol_map{
			return error('The symbol `$name` is not defined.')
		}

		symbol_index := c.symbol_map[name]

		if symbol_index.typ != .basic{
			return error('Expect a basic symbol.')
		}

		c.basic_symbol_priority_level << symbol_index.index
	}
}

pub fn (mut c Context) composite_symbol_priority_level_push(symbol_name_arr []string)?{
	for name in symbol_name_arr{
		if name !in c.symbol_map{
			return error('The symbol `$name` is not defined.')
		}

		symbol_index := c.symbol_map[name]

		if symbol_index.typ != .composite{
			return error('Expect a composite symbol.')
		}

		c.composite_symbol_priority_level << symbol_index.index
	}
}

pub fn (mut c Context) sub_composite_symbol_priority_level_push(symbol_name_arr []string)?{
	for name in symbol_name_arr{
		if name !in c.symbol_map{
			return error('The symbol `$name` is not defined.')
		}

		symbol_index := c.symbol_map[name]

		if symbol_index.typ != .sub_composite{
			return error('Expect a sub_composite symbol.')
		}

		c.sub_composite_symbol_priority_level << symbol_index.index
	}
}