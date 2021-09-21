module main
import os
import cli
import server
import server.meta
import vlsio

fn C._setmode(int, int)

fn main() {
	os.write_file(r'D:\GIT\vls-112\debug.txt','xxx') or {panic('write filed')}

	$if windows {
		// 0x8000 = _O_BINARY from <fcntl.h>
		// windows replaces \n => \r\n, so \r\n will be replaced to \r\r\n
		// binary mode prevents this
		C._setmode(C._fileno(C.stdout), 0x8000)
	}

	mut cmd := cli.Command{
		name: 'vls-112'
		version: meta.version
		description: meta.description
		execute: parse_cli
		posix_mode: true
	}

	cmd.add_flags([
		cli.Flag{
			flag: .bool
			name: 'debug'
			description: "Toggles language server's debug mode."
		},
		cli.Flag{
			flag: .bool
			name: 'socket'
			description: 'Listens and communicates to the server through a TCP socket.'
		},
		cli.Flag{
			flag: .string
			name: 'port'
			description: 'Port to use for socket communication. (Default: 5008)'
		}
	])

	cmd.parse(os.args)	
}


fn parse_cli(cmd cli.Command) ? {
	debug_mode := cmd.flags.get_bool('debug') or { false }
	//socket_mode := cmd.flags.get_bool('socket') or { false }
	//socket_port := cmd.flags.get_int('port') or { '5008' }

	// Setup the comm method and build the language server.
	// mut io := if socket_mode {
	// 	//server.ReceiveSender(Socket{ port: socket_port, debug: debug_mode })
	// } else {
	// 	server.ReceiveSender(Stdio{ debug: debug_mode })
	// }

	mut io := server.ReceiveSender(vlsio.Stdio{ debug: debug_mode })

	mut ls := server.new(io)
	ls.start_parse_loop()
}