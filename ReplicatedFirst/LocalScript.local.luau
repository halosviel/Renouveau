--[[warn("Type Error\n==> text: string expected, got number\n==> context: PlayerId must be a number  \n==> at services/testService on line 08")
warn("Error\n==> text: Module errored while requiring\n==> context: Module testService's constructor callback threw an error  \n==> at renouveau/boot on line 124")]]

--[[local log = require("@game/ReplicatedFirst/renouveau/sys/log")
log(2, "this is a test text", "this is a test context")]]

local expect = require("@game/ReplicatedFirst/renouveau/sys/expect")
expect("string", math.huge, "doing something")
print("passed")