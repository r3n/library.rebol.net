REBOL [
	Title: "Words Controller"
	Date: 16-Jul-2013
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %templates/library.rsp
]

route () to %scripts [
	get [print "SCRIPTS"]
]

route (script: string! [wordify]) to %script [
	get [
		if verify [
			description: attempt [
				require %shell/curl.r
				curl/fail join http://www.rebol.org/download-a-script.r?script-name= [script %.r]
			][
				reject 404 "Unable to Locate Script"
			]

			not parse description ["<!DOCTYPE" to end][
				reject 404 "Unable to Locate Script"
			]
		][
			where %.r [
				print description
			]
		]
	]

	get %,docs [
		if verify [
			document: attempt [
				require %shell/curl.r
				curl/fail join http://www.rebol.org/doc-download.r?format=plain&script-name= [script %.r]
			][
				reject 404 "Unable to Retrieve Document"
			]

			not find/match document "<!DOCTYPE" [ ; rebol.org doesn't return 404
				reject 404 "Document Not Found"
			]

			parse document [thru "Downloaded On" thru "^/^/" document: to end][
				reject 400 "Could Not Parse Document"
			]
		][
			require %text/clean.r
			meta: copy/part head document document
			document: clean remove/part head document document

			where/else %.rmd [
				print join meta document
			][
				require %makedoc/makedoc.r
				document: load-doc document
				render %doc
			]
		]
	]
]

