module server

fn (mut ls Vls112) initialize(id string, params string){
	ls.logger.info('initialize run',0) or {ls.exit()}
}