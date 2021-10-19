module log

import os

//Logger 输出log都通过此struct的实例
struct Logger{
	debug bool     //debug模式flg
	loglv string      //保存cli参数传入的log的输出级别 默认为0
mut:
	log_path string
	file os.File   //输出的log文件
	info_no int    //no号
	warning_no int //no号
	error_no int   //no号
}

//new_logger 创建logger param{debug:是否为debug模式 loglv:log的输出级别}
pub fn new_logger(debug bool,loglv string) Logger{
	tmp_dir := os.join_path(os.temp_dir(),'vls-112.tmp')

	if !os.is_dir(tmp_dir) {
		os.mkdir(tmp_dir) or {panic(err)}
	}

	fpath := os.join_path(tmp_dir,'vls-112-debug.log')

	if os.exists(fpath) {
		os.rm(fpath) or {panic(err)}
	}

	file:=os.open_append(fpath) or {panic(err)}

	mut logger := Logger{
		debug:debug
		file:file
		loglv:loglv
		log_path:fpath
	}

	return logger
}

//close 关闭log文件
pub fn (mut l Logger) close(){
	l.file.close()
}

//changfolder 更改log文件路径 param{folder_path:log文件夹路径}
pub fn (mut l Logger) changfolder(folder_path string)?{
	if !os.is_dir(folder_path){
		error('路径:$folder_path 不是文件夹或不存在')
	}

	log_path:=os.join_path(folder_path,'vls-112-debug.log')

	if os.exists(log_path) {
		os.rm(log_path)?
	}

	//tmplog关闭
	l.file.close()

	os.mv(l.log_path,log_path)?
	file:=os.open_append(log_path)?
	l.file = file
	l.log_path = log_path
}

//info 打印info param{msg:输出内容 loglv:log的输出级别}
pub fn (mut l Logger) info<T>(msg T,loglv int)?{
	if l.loglv[loglv..loglv + 1] == '1' && l.debug{
		defer{
			l.file.flush()
		}
		l.info_no++
		l.file.write_string('Info-No.${l.info_no}-lv${loglv}: ${msg.str()}\n')?
	}
}

//warning 打印warning param{msg:输出内容 loglv:log的输出级别}
pub fn (mut l Logger) warning<T>(msg T,loglv int)?{
	if l.loglv[loglv..loglv + 1] == '1' && l.debug{
		defer{
			l.file.flush()
		}
		l.warning_no++
		l.file.write_string('Warning-No.${l.warning_no}-lv${loglv}: ${msg.str()}\n')?
	}
}

//error 打印error param{msg:输出内容 loglv:log的输出级别}
pub fn (mut l Logger) error<T>(msg T,loglv int)?{
	if l.loglv[loglv..loglv + 1] == '1' && l.debug{
		defer{
			l.file.flush()
		}
		l.error_no++
		l.file.write_string('Error-No.${l.error_no}-lv${loglv}: ${msg.str()}\n')?
	}
}

//text 打印text param{msg:输出内容 loglv:log的输出级别 retract_str:缩进用的字符} 
pub fn (mut l Logger) text<T>(msg T,loglv int,retract_str ...string)?{
	if l.loglv[loglv..loglv + 1] == '1' && l.debug{
		defer{
			l.file.flush()
		}
		if retract_str.len == 0{
			l.file.write_string('${msg.str()}\n\n')?
		}else{
			retract := retract_str[0]

			for i,s in msg.str() {
				if i == 0{
					l.file.write_string('${retract}')?
				}

				l.file.write([s])?

				if s == `\n`{
					l.file.write_string('${retract}')?
				}

			}
			l.file.write_string('\n\n')?
		}
	}
}
