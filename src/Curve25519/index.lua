-----------------------
--// Initalization //--
-----------------------

local Curve25519 = {}

-------------------
--// Libraries //--
-------------------

local EllipticCurve25519 = require(script.Parent:WaitForChild("EllipticCurve25519"):WaitForChild("index"))

-------------------
--// Variables //--
-------------------

local Generator = Random.new(tick())
local Cryptography

-------------------
--// Functions //--
-------------------

function GenerateKey()
	local Key = table.create(32, 0)

	for Index = 1, 32 do
		Key[Index] = Generator:NextInteger(0, 255)
	end

	return Key
end

local function Package(Input)
	local Output = ""

	for _, Value in ipairs(Input) do
		Output ..= string.format("%02x", Value)
	end

	return Output
end

local function Unpackage(Input)
	local Output = {}

	local _ = string.gsub(Input, "..", function(Character)
		table.insert(Output, tonumber(Character, 16))
	end)

	return Output
end

-----------------
--// Methods //--
-----------------

function Curve25519:GenerateKeyPair()
	local Secret, Public = GenerateKey(), {}

	EllipticCurve25519.ScalarMultiplicationBase(Public, Secret)

	return {
		["Secret"] = Package(Secret),
		["Public"] = Package(Public)
	}
end

function Curve25519:GenerateSessionKey(Sender, Recipient)
	local SessionKey = {}

	EllipticCurve25519.ScalarMultiplication(SessionKey, Unpackage(Sender), Unpackage(Recipient))

	return Cryptography.Sha256(Package(SessionKey), game.JobId)
end

------------------
--// Internal //--
------------------

function Curve25519.Dependant(Parent)
	Cryptography = Parent
end

----------------------
--// Finalization //--
----------------------

return Curve25519