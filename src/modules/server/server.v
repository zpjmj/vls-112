module server

import jsonrpc
import log
import json

interface ReceiveSender {
	debug bool
	init() ?
	send(data string)
	receive() ?string
}

pub enum ServerStatus {
	off
	initialized
	shutdown
}

struct Vls112 {
	loglv int
mut:
	logger log.Logger
	status ServerStatus = .off
pub:
	io ReceiveSender
}

pub fn new(io ReceiveSender,loglv int) Vls112 {
	mut vls_112 := Vls112{
		io:io
		loglv:loglv
		logger:log.new_logger(io.debug,loglv)
	}

	vls_112.logger.text('============= vls-112 start =============',0) or {vls_112.exit()}

	return vls_112
}

//开始监听
pub fn (mut ls Vls112) start_parse_loop() {
	//go monitor_changes(mut ls)
	ls.io.init() or { panic(err) }

		// Show message that VLS is not yet ready!
	ls.show_message('VLS is a work-in-progress `debug_mode:${ls.io.debug.str()} loglv:${ls.loglv.str()}`',.info)

	for {
		payload := ls.io.receive() or { continue }
		ls.dispatch(payload)
	}
}

fn (mut ls Vls112) dispatch(payload string){
	request := json.decode(jsonrpc.Request, payload) or {
		ls.send(new_error(jsonrpc.parse_error, ''))
		return
	}

	if ls.status == .initialized {
		match request.method {
			'initialized' {}
			'shutdown' {
				ls.exit()
			}
			else {}
		}
	} else {
		match request.method {
			'exit' {
				ls.exit()
			}
			'initialize' {
				ls.initialize(request.id, request.params)
			}
			else {
				err_type := if ls.status == .shutdown {
					jsonrpc.invalid_request
				} else {
					jsonrpc.server_not_initialized
				}
				ls.send(new_error(err_type, request.id))
			}
		}
	}

	ls.logger.info('new msg -->',0) or {ls.exit()}
	ls.logger.text(request,0,'\t') or {ls.exit()}
}

fn (mut ls Vls112) exit(){
	ls.logger.text('============== vls-112 end ==============',0) or {exit(1)}
	ls.logger.close()
	exit(int(ls.status != .shutdown))
}