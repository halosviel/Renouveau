local libs = require("./_libs")
local packages = require("./_packages")

export type Module = {
	runsFirst: boolean,
	dependencies: {},
	packages: {},
	libs: {},
	constructor: ( self: Module ) -> nil,
	ready: ( self: Module ) -> nil
}

return {}