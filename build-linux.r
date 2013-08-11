REBOL [encap: [title "Cheyenne builder"]]

do %cheyenne-server-read-only/Cheyenne/svn-version.r
SDK-path: %sdk/
version: svn-version? %cheyenne-server-read-only/
publish-dir: %/home/dk/cheyenne-server.org/dl/auto/


make-name: func [encapper][
	rejoin ["bin/cheyenne-auto-linux-r" version "-" encapper]
]

zip-all: does [
	call/wait "gzip bin/*"
]

;-- Copy fresh .cache.efs file locally --
;write/binary %../Cheyenne/.cache.efs read/binary %/root/Cheyenne/.cache.efs

;-- Overwrite %encap-paths.r
call/wait "cp encap-paths.r cheyenne-server-read-only/Cheyenne/"

;-- Clean up destination folder
call/wait "rm bin/*"

;-- Enpro binary --
target: make-name "pro"
call/wait rejoin  [
	to-local-file SDK-path/tools/enpro
	" -o " target
	" cheyenne-server-read-only/Cheyenne/cheyenne.r"
]

;-- Encmd binary --
target: make-name "cmd"
call/wait rejoin  [
	to-local-file SDK-path/tools/encmd
	" -o " target
	" cheyenne-server-read-only/Cheyenne/cheyenne.r"
]

zip-all

;-- Publish new binaries
call/wait "chown dk:dk bin/*"
call/wait reform ["mv bin/*" publish-dir]

;-- Keep only last 5
list: sort/reverse read publish-dir/.
out: make string! 1000
loop 6 [
	append out rejoin [{<li><a href="dl/auto/} list/1 {">} list/1 "</a></li>^/"]
	if tail? list: next list [break] 
]
foreach file list [attempt [delete publish-dir/:file]]

write publish-dir/../../auto.inc out




