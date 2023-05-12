local Folders = {
    ["Asymmetric"] = script.Parent:WaitForChild("Asymmetric");
    ["Symmetric"] = script.Parent:WaitForChild("Symmetric");
    ["Encoding"] = script.Parent:WaitForChild("Encoding");
    ["Hashing"] = script.Parent:WaitForChild("Hashing");
}

local function Get(Type: string, Algorithm: string)
    local Module = Folders[Type]:WaitForChild(Algorithm)
    return require(if Module:IsA("ModuleScript") then Module else Module:WaitForChild("index"))
end

local Modules = {
    -- Asymmetric
    ["EC25519"] = Get("Asymmetric", "Curve25519");
    
    -- Symmetric
    ["AES"] = Get("Symmetric", "AES");

    -- Encoding
    ["Base64"] = Get("Encoding", "Base64");

    -- Hashing
    ["Sha256"] = Get("Hashing", "Sha256");
    ["Crc32"] = Get("Hashing", "Crc32").default;
}

for _, Library in Modules do
	if typeof(Library) ~= "function" and Library.Dependant ~= nil then
		Library.Dependant(Modules)
		Library.Dependant = nil
	end
end

return Modules;