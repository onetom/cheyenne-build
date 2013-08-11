REBOL [
	Title: "Tarballs builder for Cheyenne sources"
]

;--- Paramètres ---
target-dir: %cheyenne-sources/
svn-dir:    %cheyenne-server-read-only/
repo-url:   http://cheyenne-server.googlecode.com/svn/trunk/
svn-user:   "cheyenne-server-read-only"
publish-dir: %/home/dk/cheyenne-server.org/
debug?:     yes	
;------------------

shell-exec: func [cmd [string!] /local out res][
	if debug? [?? cmd]
	out: clear any [out make string! 100000]
	unless zero? res: call/wait/output cmd out [
		print [
			"Erreur SVN: " res newline
			"Commande:" cmd newline 
			"...abandon"
		]
		quit
	]
	out
]

svn-exec: func [cmd [string!] /options opt][
	shell-exec reform ["svn" cmd repo-url any [opt ""] "--username" svn-user]
]

do svn-dir/Cheyenne/svn-version.r
old-version: svn-version? svn-dir

print "Updating SVN repo..."
save-path: what-dir
change-dir svn-dir
shell-exec "svn update"
change-dir save-path
print "Update done"

version: svn-version? svn-dir
if all [
    not find any [system/script/args ""] "-f"  
    old-version = version 
][quit]

print ["New version:" version]

if exists? target-dir [shell-exec join "rm -Rf " target-dir]
out: svn-exec/options "export " target-dir

;shell-exec "rm *.zip *.gz"
shell-exec rejoin ["tar zcf cheyenne-sources-r" version ".tar.gz " target-dir]
shell-exec rejoin ["zip -r cheyenne-sources-r" version ".zip " target-dir]
shell-exec join "rm -Rf " target-dir

shell-exec rejoin ["mv *.zip *.gz " publish-dir/tmp]
name.tgz: rejoin ["cheyenne-sources-r" version ".tar.gz"]
name.zip: rejoin ["cheyenne-sources-r" version ".zip"]

write publish-dir/tarballs.inc build-markup {
	<li><a href="/tmp/<%name.tgz%>"><%name.tgz%></a></li>
	<li><a href="/tmp/<%name.zip%>"><%name.zip%></a></li>
}

print "building new binaries..."
do %build-linux.r

print "all done."
quit
