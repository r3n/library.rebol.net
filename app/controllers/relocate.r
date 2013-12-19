REBOL [
	Title: "Relocate"
	Date: 19-Dec-2013
	Author: "Christopher Ross-Gill"
	Type: 'controller
]

route ("view-script") to relocate [
	verify [
		params: validate request/query [
			script: file! [wordify ".r"]
		][
			reject 400 "Bad Request"
		]
	]

	get [
		clear find script: params/script ".r"
		redirect-to scripts/(script)
	]
]

route ("download-a-script") to relocate [
	verify [
		params: validate request/query [
			script-name: file! [wordify ".r"]
		][
			reject 400 "Bad Request"
		]
	]

	get [
		redirect-to scripts/(params/script-name)
	]
]

route ("st-topic-details") to relocate [
	verify [
		params: validate request/query [
			tag: string! [wordify opt ["//" wordify]]
		][
			reject 400 "Bad Request"
		]
	]

	get [
		redirect-to tags/(params/tag)
	]
]