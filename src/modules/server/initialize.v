module server

import lsp
import json

fn (mut ls Vls112) initialize(id string, params string)?{

	initialize_params := json.decode(lsp.InitializeParams, params) or {
		ls.logger.error('initialize-->',0)?
		ls.logger.text(err,0,'\t')?
		return err
	}

	ls.logger.info('vvvvvv',0)?
	ls.logger.info('initialize-->',0)?
	ls.logger.text(params,0,'\t')?
	ls.logger.text(initialize_params.process_id,0,'\t')?

	ls.logger.info('xxxxxx',0)?

}