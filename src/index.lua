local Curve25519 = require(script:WaitForChild("Curve25519"));

local Modules = script:WaitForChild("Modules");
local function Load(Name)
    return require(Modules:WaitForChild(Name))
end

return {
    ["EC25519"] = Curve25519;
    
    ["AES"] = Load("AES");
    ["Base64"] = Load("Base64");
    ["Sha256"] = Load("Sha256");
};