local libs = require("./_libs")
local packages = require("./_packages")

export type SessionLogD = {
	runsFirst: boolean,
	dependencies: {},
	packages: {},
	libs: {},
	JOIN_LOGS_ENABLED: boolean,
	VERSION: string,
	constructor: ( self: SessionLogD ) -> nil,
	ready: ( self: SessionLogD ) -> nil
}


return {}