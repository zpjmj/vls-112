module server

import jsonrpc
import json

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

fn (mut ls Vls112) notify<T>(data jsonrpc.NotificationMessage<T>)? {
	str := json.encode(data)

	// ls.logger.in
	ls.io.send(str)?
}

fn (mut ls Vls112) show_message(m string, mlv MessageType)? {
	ls.notify(jsonrpc.NotificationMessage<ShowMessageParams>{
		method: 'window/showMessage'
		params: ShowMessageParams{
			@type: mlv
			message: m
		}
	})?
}

fn (mut ls Vls112) send<T>(resp jsonrpc.Response<T>) ? {
	str := resp.json()
	ls.logger.info('new response -->', 1)?
	ls.logger.text(str, 1, '\t')?
	ls.io.send(str)?
}

fn (mut ls Vls112) send_null(id string) ? {
	str := '{"jsonrpc":"$jsonrpc.version","id":$id,"result":null}'
	ls.logger.info('new response -->', 1)?
	ls.logger.text(str, 1, '\t')?
	ls.io.send(str)?
}

[inline]
fn new_error(code int, id string) jsonrpc.Response<string> {
	return jsonrpc.Response<string>{
		id: id
		error: jsonrpc.new_response_error(code)
	}
}

[inline]
fn uri_to_path(uri string) string {
	$if windows {
		if uri.contains('%3A') {
			return uri.all_after('file:///').replace_each(['/', '\\', '%3A', ':'])
		}
	}
	return if uri.starts_with('file://') { uri.all_after('file://') } else { '' }
}
