module symboldb
//符号规约库

pub const scan_end = byte(0b0)

//符号判断函数 
pub type FuncSymbolBool = fn(Symbol,int)(bool,int,int,int)  //flg symbol_step match_fn_step tier
pub type FuncByteBool = fn([]byte)bool

pub enum Symboltype{
	//未被定义的
	undefined
	//基本
	basic
	//组合
	composite
}

//符号
pub struct Symbol{
pub:
	//名字
	name string
	//类型
	typ Symboltype
	//文字范围
	text_range Range
	//字节范围
	byte_range Range
	////自定义属性
	//user_def_attr map[string]string
}

//范围 左闭右开
pub struct Range{
	start int
	end int
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
