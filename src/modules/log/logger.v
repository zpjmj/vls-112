module log

struct Logger{
	fd 

}

pub fn new_logger(debug bool) Logger{
	mut logger := Logger{}


	return logger
}

pub fn (mut l Logger) 