--[=[
	[INFO]
	author: @halosviel
	created: 2026 March 7
	
	[DESCRIPTION]
	Applies knockback and lift to the part in the direction of lookVector.
	
	[EXAMPLES]
	applyKnockback(part, Vector3.new(0, 0, 1), 25, 5)
	
	[UPDATES]
	(excludes compatibility updates for different frameworks)
	- 2026 June 02: Made the module compatible with parts, not just players specifically.
	- 2026 July 18: Made the `lift` parameter optional.
]=]

local log = require("@game/ReplicatedFirst/renouveau/sys/log")
local expect = require("@game/ReplicatedFirst/renouveau/sys/expect")

return function(part: Part, lookVector: Vector3, force: number, lift: number?)
	--# dont assert targetCharacter -> anything can happen at runtime!
	if typeof(part) ~= "Instance" or typeof(part) == "Instance" and not part:IsA("BasePart") then
		log(4, "Type mismatch", "Applying knockback", {{ "expected", "BasePart" }, { "got", typeof(part) }})
		return
	end
	
	expect("Vector3", lookVector)
	expect("number", force)

	local velocity: Vector3 = lookVector * force
	if lift ~= nil then
		expect("number", lift)
		velocity = velocity + Vector3.new(0, lift, 0)
	end
	
	local attachment: Attachment = Instance.new("Attachment")
	attachment.Name = "KnockbackAttachment"
	attachment.Parent = part
	
	local linearVelocity: LinearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = velocity
	linearVelocity.MaxForce = math.huge
	linearVelocity.Parent = part
	
	game.Debris:AddItem(attachment, 0.15)
	game.Debris:AddItem(linearVelocity, 0.15)
end