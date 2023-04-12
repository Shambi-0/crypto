local Curve25519 = require(script:WaitForChild("Curve25519"));

local Modules = script:WaitForChild("Modules");

local AES = require(Modules:WaitForChild("AES"));

return {
    ["EC25519"] = Curve25519;
    ["AES"] = AES;
};