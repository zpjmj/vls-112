module server

import jsonrpc
import log
import json
import lsp

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
	//储存log 信息输出等级
	loglv string
	vexe string
mut:
	//log输出用对象
	logger log.Logger
	//保存server状态
	status ServerStatus = .off
	//保存客户端rootpath
	root_path string
	//服务端提供那些能力
	capabilities lsp.ServerCapabilities
	//符号db
	symboldb Symboldb
pub:
	//io流对象用于与客户端传递信息
	io ReceiveSender
}

pub fn new(io ReceiveSender,loglv string,vexe string) Vls112 {
	mut vls_112 := Vls112{
		io:io
		loglv:loglv
		logger:log.new_logger(io.debug,loglv)
		vexe:vexe
	}

	vls_112.logger.text('============= vls-112 start =============',0) or {vls_112.vls112_exit(1,err)}

	return vls_112
}

//开始监听
pub fn (mut ls Vls112) start_parse_loop() {
	//go monitor_changes(mut ls)
	ls.io.init() or { panic(err) }

		// Show message that VLS is not yet ready!
	ls.show_message('VLS-112 is a work-in-progress `debug_mode:${ls.io.debug.str()} loglv:${ls.loglv.str()}`',.info)

	for {
		payload := ls.io.receive() or { continue }
		ls.dispatch(payload) or {ls.vls112_exit(1,err)}
	}
}

fn (mut ls Vls112) dispatch(payload string)?{
	request := json.decode(jsonrpc.Request, payload) or {
		ls.send(new_error(jsonrpc.parse_error, ''))?
		return
	}

	ls.logger.info('new request -->',1)?
	ls.logger.text(request,1,'\t')?

	if ls.status == .initialized {
		match request.method {
			'initialized' {}
			'shutdown' {
				ls.shutdown(request.id)?
			}
			'textDocument/definition' {
				ls.definition(request.id, request.params)?
			}
			'textDocument/codeLens'{
				ls.send_null(request.id)?
			}
			else {}
		}
	} else {
		match request.method {
			'exit' {
				ls.vls112_exit(0)
			}
			'initialize' {
				ls.initialize(request.id, request.params)?
			}
			else {
				err_type := if ls.status == .shutdown {
					jsonrpc.invalid_request
				} else {
					jsonrpc.server_not_initialized
				}
				ls.send(new_error(err_type, request.id))?
			}
		}
	}
}

fn (mut ls Vls112) vls112_exit(exit_code int,vls_error ...IError){
	if exit_code != 0 {
		ls.logger.error('-->',0) or {exit(exit_code)}
		ls.logger.text(vls_error[0],0,'\t') or {exit(exit_code)}
	}

	ls.logger.text('============== vls-112 end ==============',0) or {exit(exit_code)}
	ls.logger.close()
	exit(exit_code)
}

fn (mut ls Vls112) shutdown(id string)? {
	ls.status = .shutdown
	ls.send_null(id)?
	ls.vls112_exit(0)
}