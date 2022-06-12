module vlsio

import strings
import log
import os

const (
	content_length = 'Content-Length: '
)

fn C.fgetc(stream &C.FILE) int

pub struct Stdio {
mut:
	stdout os.File = os.stdout()
pub mut:
	debug bool
	logger log.Logger
}

pub fn (_ Stdio) init() ? {}

pub fn (mut s Stdio) send(output string)? {
	defer { s.stdout.flush() }
	s.stdout.write('Content-Length: $output.len\r\n\r\n$output'.bytes())?
}

//[manualfree]
pub fn (mut s Stdio) receive() ?string {
	first_line := get_raw_input()
	if first_line.len < 1 || !first_line.starts_with(vlsio.content_length) {
		return error('content length is missing')
	}
	mut conlen := first_line[vlsio.content_length.len..].int()
	mut buf := strings.new_builder(conlen)
	for conlen >= 0 {
		c := C.fgetc(&C.FILE(C.stdin))
		$if !windows {
			if c == 10 {
				continue
			}
		}
		buf.write_u8(u8(c))
		conlen--
	}
	payload := buf.str()
	//unsafe { buf.free() }
	return payload[1..]
}

fn get_raw_input() string {
	eof := C.EOF
	mut buf := strings.new_builder(100)
	for {
		c := C.fgetc(&C.FILE(C.stdin))
		chr := u8(c)
		if buf.len > 2 && (c == eof || chr in [`\r`, `\n`]) {
			break
		}
		buf.write_u8(chr)
	}
	return buf.str()
}

pub fn (_ Stdio) close() {
	return
}
