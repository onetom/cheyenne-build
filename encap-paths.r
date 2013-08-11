;=== Copy this file and set your own encap paths

;--- Windows include paths ---
#if [system/version/4 = 3] [
	#include %//dev/SDK/v278/Source/mezz.r
	#include %//dev/SDK/v278/Source/prot.r
	#include %//dev/SDK/v278/Source/gfx-colors.r
]
;--- OS X include paths ---
#if [system/version/4 = 2] [
	#include %/Users/dk/Desktop/sdk-278/source/mezz.r
	#include %/Users/dk/Desktop/sdk-278/source/prot.r
	#include %/Users/dk/Desktop/sdk-278/source/gfx-colors.r
]
;--- Linux include paths ---
#if [system/version/4 = 4] [
	#include %/usr/dk/tarballs/sdk/source/mezz.r
	#include %/usr/dk/tarballs/sdk/source/prot.r
	#include %/usr/dk/tarballs/sdk/source/gfx-colors.r
]

