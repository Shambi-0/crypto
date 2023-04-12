local Curve25519 = require(script.Parent:WaitForChild("Curve25519"):WaitForChild("index"));

local Modules = script.Parent:WaitForChild("Modules");

local function Load(Name)
    return require(Modules:WaitForChild(Name))
end

Modules = {
    ["EC25519"] = Curve25519;
    
    ["AES"] = Load("AES");
    ["Base64"] = Load("Base64");
    ["Sha256"] = Load("Sha256");
}

for _, Library in Modules do
	if typeof(Library) ~= "function" and Library.Dependant ~= nil then
		Library.Dependant(Modules)
		Library.Dependant = nil
	end
end

return Modules;