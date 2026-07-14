local libs = require("./libs")
local packages = require("./packages")

export type MyModule = {
	dependencies: {},
	packages: { },
	libs: { promise: libs.Promise },
	constructor: ( self: MyModule ) -> nil,
	ready: ( self: MyModule ) -> nil,
}

return {}