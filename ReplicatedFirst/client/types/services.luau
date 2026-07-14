local libs = require("./_libs")
local packages = require("./_packages")

export type MyModule = {
	dependencies: { module1: Module1 },
	packages: {},
	libs: {},
	constructor: ( self: MyModule ) -> nil,
	ready: ( self: MyModule ) -> nil,
}

export type Module1 = {
	dependencies: {},
	packages: {},
	libs: {},
	constructor: ( self: Module1 ) -> nil,
	test: ( self: Module1 ) -> nil,
	ready: ( self: Module1 ) -> nil,
}

return {}