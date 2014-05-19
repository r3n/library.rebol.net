Rebol [
	Title: "Read Cached Or New"
	Date:  6-Mar-2014
	Author: "Christopher Ross-Gill"
	Version: 0.1.0
	Type: 'module
	Exports: [read-cached-or-new]
	Within: 0:10
]

read-cached-or-new: func [
	"Reads a remote resource unless a recent local cached version exists."
	target [url!] "Remote Resource"
	cached [file! url!] "Cache Location"
	/aged interval [time!]
	/as agent [string!]
	/binary
][
	interval: any [interval header/within]

	unless all [
		exists? cached
		greater? interval difference now modified? cached
	][
		; ; should read in chunks then clear memory used
		; write/binary cached read/binary target
		require %shell/curl.r
		write/binary cached curl/binary/as target agent
	]

	either binary [
		read/binary cached
	][
		read cached
	]
]