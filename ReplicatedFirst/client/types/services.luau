local libs = require("./_libs")
local packages = require("./_packages")

export type MyModule = {
	dependencies: {},
	packages: { },
	libs: { promise: libs.Promise },
	constructor: ( self: MyModule ) -> nil,
	ready: ( self: MyModule ) -> nil,
}

return {}