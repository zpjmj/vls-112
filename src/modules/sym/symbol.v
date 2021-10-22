module sym
//符号规约

pub const scan_end = byte(0b0)

//符号判断函数
//input: basic_symbol,tier,scope_index_arr
//output: flg symbol_step match_fn_step tier
pub type FuncSymbolBool = fn(Symbol,int,mut []int)(bool,int,int,int)
pub type FuncByteBool = fn([]byte)bool

pub enum Symboltype{
	//未被定义的
	undefined
	//基本
	basic
	//组合
	composite
	//子组合
	sub_composite
}

//符号
pub struct Symbol{
pub:
	//名字
	name string
	//类型
	typ Symboltype
	//扫描器引用
	scanner &Scanner
	//文字范围
	text_range Range
	//字节范围
	byte_range Range
	//all_basic_symbol数组中的索引 end_index只对组合符号有意义
	start_index int
	end_index int
	//闭合符号的开始结束index数组 () [] {}
	scope []int
}

struct SymbolStr{
	name string
	//类型
	typ Symboltype
	start_index int
	end_index int
	text string
	scope []int
}

pub fn (sym Symbol) str()string{
	text := sym.get_text()
	mut index := 0
	for i,s in text{
		if s == `\n`{
			if i > 0 {
				x := text[i - 1]
				if x == `\r`{
					index = i - 1
				}else{
					index = i
				}
			}else{
				index = i
			}
			break
		}
	}

	if index ==  0 {
		index = text.len
	}

	ss := SymbolStr{
		name:sym.name
		typ:sym.typ
		start_index:sym.start_index
		end_index:sym.end_index
		text:text[0..index] 
		scope:sym.scope
	}
	return ss.str()
}

//范围 左闭右开
pub struct Range{
pub:
	start int
	end int
	start_line int
	start_character int
	end_line int
	end_character int
}

//基本符号 不可分割的最小元素
//basic symbol

//组合符号 由2个或2个以上基本符号组合而成
//composite symbol

//基本符号
pub struct BasicSymbol{
	//符号名称
	name string
	//符号匹配定义
	define BasicSymbolDefine
}

//基本符号匹配定义
pub struct BasicSymbolDefine{
	//匹配开始
	is_start fn([]byte)bool [required]
	//是否固定长度
	is_fixed_length bool [required]
	//固定长度
	len int [required]
	//可变长继续匹配函数
	is_continue fn([]byte)bool [required]
	//匹配结束
	is_end fn([]byte)bool [required]
	//is_continue函数传入后续所有字符
	continue_fn_input_all bool
	//发生比正确匹配是是否跳过不输出undefined
	on_error_skip bool
}

//组合符号
pub struct CompositeSymbol{
	//符号名称
	name string
	//符号匹配定义
	define CompositeSymbolDefine
}

//组合符号匹配定义
pub struct CompositeSymbolDefine{
	//匹配开始
	is_start fn(Symbol)bool [required]
	//内容匹配函数数组
	match_fn_arr []FuncSymbolBool [required]
mut:
	//能否继续
	can_continue FuncSymbolBool [required]
	//当前匹配函数index
	match_fn_index int [required]
}

//子组合符号
pub struct SubCompositeSymbol{
	//组合符号定义
	composite_symbol CompositeSymbol
	//依赖那些组合符号
	parent []string
	//父类scope index
	scope_index map[string][]int  //空数组表示全范围
}

pub fn (s Symbol) get_text() string{
	return s.scanner.text[s.byte_range.start..s.byte_range.end]
}

pub fn new_empty_symbol()Symbol{
	scanner := new_scanner('')
	return Symbol{
		scanner:&scanner
	}
}