#!/usr/local/bin/v run
import os

param := os.args[1..]

mut gc:='-gc boehm '
mut prod := ''

if param.len > 0 {
	if param[0] == '-prod' {
		prod = '-prod '
		gc = '-gc boehm '
	}
}

pwd := getwd()

src_path := join_path(pwd, 'src', '')

vls_112_source_path := join_path(src_path, 'vls-112.v')

vls_112_exec_path := join_path(pwd, 'vls-112')

commend := @VEXE + ' $prod$gc"$vls_112_source_path" -o "$vls_112_exec_path"'
println(commend)

re := system(commend)

if re != 0 {
	println('Failed building VLS-112')
	return
}

println('> VLS-112 built successfully!')
println('Executable saved in: $vls_112_exec_path')