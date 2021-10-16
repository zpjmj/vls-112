module server

struct VlsAstFile{
	//存储所有模块
	modules map[string]string
	structs map[string]string 
	functions map[string]string
	scope
}


fn (mut ls Vls112) source_parse(fpath string,line int,character int){

}