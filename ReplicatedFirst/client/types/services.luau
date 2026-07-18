export type Module = {
	runsFirst: boolean,
	dependencies: {},
	constructor: ( self: Module ) -> nil,
	ready: ( self: Module ) -> nil
}

return {}