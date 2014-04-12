REBOL [
	Title: "Make-Doc Text Dialect Parser"
	Author: ["Carl Sassenrath" "Christopher Ross-Gill"]
	Type: 'document
]

(
	rmd-cell: use [content mark][
		content: complement charset "[^/"
		[copy text some [some content | mark: "[cell" :mark break | "["]]
	]
)

some [ ;here: (print here)
	  any space newline
	;-- Headers / End of file
	| "===" line (emit sect1 text)
	| "---" line (emit sect2 text)
	| "+++" line (emit sect3 text)
	| "..." line (emit sect4 text)
	| "###" to end (emit end none)

	;-- Special common notations:
	| "*" [
		  ">>" lines (emit bullet3 para)
		| ">" lines (emit bullet2 para)
		| lines (emit bullet para)
	]
	| "#" [
		  ">>" lines (emit enum3 para)
		| ">" lines (emit enum2 para)
		| lines (emit enum para)
	]
	| #":" define (
		emit define-term text
		emit define-desc para
	)

	;-- Special sections:
	| #"\" [
		  "in" term (emit indent-in text)
		| "grid" block (emit grid-in values)
		| "note" line (emit note-in text)
		| "define" line (emit define-in text)
		| "quote" block (emit quote-in values)
		| ["box" | "section" | "column"] block (emit box-in values)
		| "aside" term (emit boxout-in none)
		| "table condensed" term (emit table-in-condensed none)
		| "table" term (emit table-in copy [])
		| "table" line (emit table-in text)
		| "group" term (emit group-in none)
		| "pullquote" term (emit pullquote-in none)
		| "list" block (emit list-in values)
		| "figure" term (emit figure-in none)
		| "sidebar" term (emit sidebar-in none)
	]

	| #"/" [
		  "in" term (emit indent-out none)
		| "grid" block (emit grid-out none)
		| "note" term (emit note-out none)
		| "define" term (emit define-out none)
		| "quote" [line (emit quote-out text) | term (emit quote-out none)]
		| ["box" | "section" | "column"] term (emit box-out none)
		| "aside" term (emit boxout-out none)
		| "table" term (emit table-out none)
		| "group" term (emit group-out none)
		| "pullquote" term (emit pullquote-out none)
		| "list" term (emit list-out none)
		| "figure" term (emit figure-out none)
		| "sidebar" term (emit sidebar-out none)
	]

	;-- Commands:
	| #"=" [
		  "banner" term (emit banner none)
		| "caption" lines (emit caption para)
		| "row" term (emit table-row none)
		| "next" term (emit next none)
		| "image" block (emit image values)
		| "youtube" block (emit youtube values)
		| "vimeo" block (emit vimeo values)
		| "icon" block (emit icon values)
		| "url" block (emit url values)
		| "options" block (append options values)
		| ">" line (emit brief text)
		| ["item" | "next"] term (emit list-item none)
		| "place" opt "s" commas (emit place values)
		| "topic" opt "s" commas (emit topics values)
		| ["break" | "hr"] term (emit break none)
	]
	
	;-- URLs:
	| url-start [
		  "instagram.com" url-block (emit instagram values)
		| ["youtube.com" | "youtu.be"] url-block (emit youtube values)
		| "vimeo.com" url-block (emit vimeo values)
		| "flickr.com" url-block (emit flickr values)
	]

	;-- Supporting other rebol.org document type
	| "[h1" line (emit para text)
	| "[h2" line (emit sect1 text)
	| "[h3" line (emit sect2 text)
	| "[p" lines (emit para para)
	| "[numbering-on" term
	| "[contents" term
	| "[asis" thru newline copy para to "asis]" "asis]" term (
		emit/verbatim code replace/all para "&gt;" ">"
	)
	| "[table" line (emit table-in none)
	| "[row" term (emit table-row none)
	| "table]" term (emit table-out none)
	| "[li" line (emit bullet text)
	| "[cell" rmd-cell (emit para text)

	;--Defaults:
	| ";" lines  ; comment
	| example (emit/verbatim code para)
	| paragraph (emit para para)
	| skip
]