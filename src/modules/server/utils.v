module server

import jsonrpc
import json
import strings

struct ShowMessageParams {
	@type MessageType
	// @type int
	message string
}

enum MessageType {
	error = 1
	warning = 2
	info = 3
	log = 4
}

fn (mut ls Vls112) notify<T>(data jsonrpc.NotificationMessage<T>) {
	str := json.encode(data)
	//ls.logger.in
	ls.io.send(str)
}

fn (mut ls Vls112) show_message(m string,mlv MessageType){
	ls.notify(jsonrpc.NotificationMessage<ShowMessageParams>{
		method: 'window/showMessage'
		params: ShowMessageParams{
			@type: mlv
			message: m
		}
	})
}

fn (mut ls Vls112) send<T>(resp jsonrpc.Response<T>) {
	mut resp_wr := strings.new_builder(100)
	defer { unsafe { resp_wr.free() } }
	resp_wr.write_string('{"jsonrpc":"${jsonrpc.version}","id":${resp.id}')
	if resp.id.len == 0 {
		resp_wr.write_string('null')
	}
	if resp.error.code != 0 {
		err := json.encode(resp.error)
		resp_wr.write_string(',"error":${err}')
	} else {
		res := json.encode(resp.result)
		resp_wr.write_string(',"result":${res}')
	}
	resp_wr.write_b(`}`)
	str := resp_wr.str()
	ls.io.send(str)
}

[inline]
fn new_error(code int, id string) jsonrpc.Response<string> {
	return jsonrpc.Response<string>{
		id: id
		error: jsonrpc.new_response_error(code)
	}
}