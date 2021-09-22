module server

import lsp
import json

fn (mut ls Vls112) initialize(id string, params string)?{

	initialize_params := json.decode(lsp.InitializeParams, params) or {
		ls.logger.error('initialize-->',0)?
		ls.logger.text(err,0,'\t')?
		return err
	}

	ls.logger.info('initialize.workspaceFolders.uri-->',0)?
	ls.logger.text(initialize_params.workspace_folders,0,'\t')?

}