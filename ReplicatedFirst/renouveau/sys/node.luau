

export type Node = {
	
}

local Node = {}

function Node.new()
	local self = setmetatable({
		
	}, Node)
	return self
end

Node.__index = Node
return Node