export type Module = {
	runsFirst: boolean,
	dependencies: {},
	packages: { soundUtils: packages.SoundUtils },
	libs: {},
	constructor: ( self: Module ) -> nil,
	ready: ( self: Module ) -> nil
}

return {}