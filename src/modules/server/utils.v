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

