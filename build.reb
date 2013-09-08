Rebol [
	Title: "Cheyenne builder"
	Encap: [title "Cheyenne builder"]
	Description: {
		; the build script
		build-dir/build.reb

		; dependencies
			; virtual file-system to be encapped
			build-dir/.cache.efs

			; SDK tools and sources
			sdk
			sdk/tools/en*
			sdk/tools/license.key
			sdk/sources

		; generated files
			; lists for a limited number of latest build and download file names
			build-dir/latest-builds.reb
			build-dir/latest-dists.reb

			; source repository
			repo
			; file to be encapped
			repo/Cheyenne/cheyenne.r
			; virtual file-system to be encapped
			repo/Cheyenne/.cache.efs
			; rebol sources to include from the SDK
			repo/Cheyenne/encap-paths.r

			; HTML snippets to be included on http://cheyenne-server.org/download.shtml
			www-dir/builds.inc
				<li><a href="download-path/cheyenne-linux-afcc99e-pro.gz">cheyenne-linux-afcc99e-pro.gz</a></li>
				<li><a href="download-path/cheyenne-linux-afcc99e-cmd.gz">cheyenne-linux-afcc99e-cmd.gz</a></li>
				...

			www-dir/dists.inc
				<li><a href="download-path/cheyenne-afcc99e-pro.gz">cheyenne-afcc99e-pro.gz</a></li>
				<li><a href="download-path/cheyenne-afcc99e-cmd.gz">cheyenne-afcc99e-cmd.gz</a></li>
				...
				; for an alternative reliable source maybe?
				<li><a href="https://github.com/dockimbel/cheyenne/archive/master.tar.gz">cheyenne-master.tar.gz</a><li>
				<li><a href="https://github.com/dockimbel/cheyenne/archive/master.zip">cheyenne-master.zip</a><li>

			; downloads
			publish-dir/cheyenne-linux-afcc99e-pro.gz
			publish-dir/cheyenne-linux-afcc99e-cmd.gz
			publish-dir/cheyenne-afcc99e.tar.gz
			publish-dir/cheyenne-afcc99e.zip

			; for convenience
			publish-dir/cheyenne-linux-latest-pro.gz
			publish-dir/cheyenne-linux-latest-cmd.gz
			publish-dir/cheyenne-latest.tar.gz
			publish-dir/cheyenne-latest.zip
	}
]

build-dir: clean-path system/options/path
sdk: build-dir/sdk
repo: build-dir/cheyenne
www-dir: %/home/dk/cheyenne-server.org/
download-path: %dl
publish-dir: www-dir/:download-path

build: does [
	make-dir/deep www-dir
	make-dir/deep publish-dir
	update-source
	build-cache.efs
	build-encap-paths.r
	publish-builds reduce [build-exe pro]
	publish-dists reduce [build-dist %.tar.gz   build-dist %.zip]
]

update-source: does [
	unless dir? repo/.git [ exec git {clone https://github.com/dockimbel/cheyenne/} ]
	exec git {pull}
]
	exec: funct [params /read] [
		params: reform params
		either read
			[call/wait/output params output: copy ""   output]
			[call/wait params]
	]
	git: funct [params] [ reform join [join {GIT_DIR=} repo/.git {git}] params ]

build-cache.efs: does [ in-dir repo/Cheyenne [do/args %cheyenne.r {-e}] ]
build-encap-paths.r: does [
	write repo/%Cheyenne/encap-paths.r
		map-each file [mezz.r prot.r gfx-colors.r]
			[ rejoin [{#include %} clean-path sdk/source/:file newline] ]
]

publish-builds: funct [builds] [
	write www-dir/builds.inc
		build-inc download-path
			queue build-dir/latest-builds.reb builds 5 * 2	; 5 pairs of pro and cmd builds
]
	build-inc: funct [download-path files] [
		ajoin map-each file files [ li-a download-path/:file file ]
	]
		li-a: funct [href txt] [
			ajoin [<li> build-tag[a href (href)] txt </a> </li> newline]
		]

	queue: funct [q files limit] [
		past-files: any [ attempt [load q] [ ] ]
		new-files: push/limit past-files files limit
		obsolete-files: copy/part   new-files   head new-files
		save q new-files
		foreach build obsolete-files [ delete build ]
		new-files
	]
		push: funct [q items /limit size] [
			skip   tail union q items   negate size
		]

build-exe: funct ['encapper] [
	exe: exe-name :encapper
	exec encap publish-dir/:exe :encapper
	exe
]
	make-timestamp: does [
		rejoin [
			either now/day < 10 [join "0" now/day][now/day]
			lowercase copy/part pick system/locale/months now/month 3
			now/year - 2000
		]
	]
	exe-name: funct ['encapper] [ rejoin [%cheyenne-linux- ver %- :encapper] ]
		ver: does [ 
			ver: rejoin [
				make-timestamp #"-"
				trim/lines exec/read git {rev-parse --short HEAD}
			]
		]
	encap: funct [exe 'encapper] [
		reduce [
			to-local-file sdk/tools/(join {en} :encapper)
			"-o" exe
			repo/Cheyenne/cheyenne.r
		]
	]

publish-dists:  funct [dists] [
	write www-dir/dists.inc
		build-inc download-path
			queue build-dir/latest-dists.reb dists 5 * 2	; 5 pairs of .tar.gz and .zip sources
]

build-dist: funct [ext] [
	dist-file: join dist-name ext
	exec git [{archive -o} publish-dir/:dist-file {HEAD}]
	dist-file
]
	dist-name: funct [] [ rejoin [%cheyenne- ver] ]

build
