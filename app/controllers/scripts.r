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

			parse description ["<!DOCTYPE to end"][
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
				reject 404 "Unable to Locate Document"
			]

			parse document [thru "Downloaded On" thru "^/^/" document: to end][
				either parse document ["<!DOCTYPE" to end][ ; rebol.org doesn't return 404
					reject 404 "Document Not Available"
				][
					reject 400 "Could Not Parse Document"
				]
			]
		][
			require %text/clean.r
			clean head document

			where/else %.rmd [
				print head document
			][
				require %makedoc/makedoc.r
				document: load-doc document
				render %doc
			]
		]
	]
]

