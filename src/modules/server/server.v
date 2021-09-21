module server

interface ReceiveSender {
	debug bool
	init() ?
	send(data string)
	receive() ?string
}

struct Vls112 {
pub:
	io ReceiveSender
}

pub fn new(io ReceiveSender) Vls112 {
	vls_112 := Vls112{
		io:io
	}

	return vls_112
}

//开始监听
pub fn (mut ls Vls112) start_parse_loop() {
	//go monitor_changes(mut ls)
	ls.io.init() or { panic(err) }

		// Show message that VLS is not yet ready!
	ls.show_message('VLS is a work-in-progress.',.warning)

	// for {
	// 	payload := ls.io.receive() or { continue }
	// 	ls.dispatch(payload)
	// }
}

