module server

import lsp
import json112
import jsonrpc

fn (mut ls Vls112) initialize(id string, params string)?{
	initialize_params := json112.decode(params) or {
		ls.logger.error('initialize-->',0)?
		ls.logger.text(err.str(),0,'\t')?
		return err
	}

	node_root_path := json112.node('rootPath')
	if initialize_params.exist(node_root_path) {
		ls.root_path = initialize_params.val<string>(node_root_path)
	}else{
		return error('initialize--> rootPath not exist')
	}

	ls.logger.changfolder(ls.root_path) or {
		ls.logger.error('initialize-->',0)?
		ls.logger.text(err.str(),0,'\t')?
		return err
	}

	ls.capabilities = lsp.ServerCapabilities{
		//text_document_sync: .incremental
		//text_document_sync:.full
		definition_provider: true
		// completion_provider: lsp.CompletionOptions{
		// 	resolve_provider: true
		// }
	}

	result := jsonrpc.Response<lsp.InitializeResult>{
		id: id
		result: lsp.InitializeResult{
			capabilities: ls.capabilities
		}
	}

	ls.status = .initialized
	ls.send(result)?
}