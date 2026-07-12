export type CodeInfo = {
	title: string,
	callback: ( ...any ) -> any
}

return {
	[1] = {
		title = "Code Error",
		callback = error
	},
	[2] = {
		title = "Setup Error",
		callback = error
	},
	[3] = {
		title = "Error",
		callback = warn
	},
	[4] = {
		title = "Warning",
		callback = warn
	},
	[5] = {
		title = "Print",
		callback = print
	}
}