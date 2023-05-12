local Permutations = table.freeze({

	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2

})

local function ProcessNumber(Input, Length)
	local Output = ""

	for _ = 1, Length do
		local Remainder = bit32.band(Input, 255)

		Output ..= string.char(Remainder)
		Input = bit32.rshift(Input - Remainder, 8)
	end

	return string.reverse(Output)
end

local function StringTo232BitNumber(Input, Offset)
	local Output = 0

	for Index = Offset, Offset + 3 do
		Output *= 256
		Output += string.byte(Input, Index)
	end

	return (Output)
end

local function PreProcess(Content, Length)
	return Content .. "\128" .. string.rep("\0", 64 - bit32.band(Length + 9, 63)) .. ProcessNumber(8 * Length, 8)
end

local function Digestblock(Content, Offset, Hash)
	local Offsets = {}

	for Index = 1, 16 do 
		Offsets[Index] = StringTo232BitNumber(Content, Offset + (Index - 1) * 4) 
	end

	for Index = 17, 64 do
		local Value = Offsets[Index - 15]
		local Section0 = bit32.bxor(bit32.rrotate(Value, 7), bit32.rrotate(Value, 18), bit32.rshift(Value, 3))

		Value = Offsets[Index - 2]
		Offsets[Index] = Offsets[Index - 16] + Section0 + Offsets[Index - 7] + bit32.bxor(bit32.rrotate(Value, 17), bit32.rrotate(Value, 19), bit32.rshift(Value, 10))
	end

	local a, b, c, d, e, f, g, h = Hash[1], Hash[2], Hash[3], Hash[4], Hash[5], Hash[6], Hash[7], Hash[8]

	for Index = 1, 64 do
		local Section0 = bit32.bxor(bit32.rrotate(a, 2), bit32.rrotate(a, 13), bit32.rrotate(a, 22))
		local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c))

		local Tail2 = Section0 + maj
		local Section1 = bit32.bxor(bit32.rrotate(e, 6), bit32.rrotate(e, 11), bit32.rrotate(e, 25))
		local Chunk = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
		local Tail1 = h + Section1 + Chunk + Permutations[Index] + Offsets[Index]

		h, g, f, e, d, c, b, a = g, f, e, d + Tail1, c, b, a, Tail1 + Tail2
	end

	for Index, Value in { a, b, c, d, e, f, g, h } do
		Hash[Index] = bit32.band(Hash[Index] + Value)
	end
end

return function(Content, Salt)
	assert(type(Content) == "string", "Argument #1 must be type\"string\".")

	Content ..= if type(Salt) == "string" then "_" .. Salt else ""
	Content = PreProcess(Content, #Content)

	local Hash = table.create(8)
	local Base = {
		0x6a09e667,
		0xbb67ae85,
		0x3c6ef372,
		0xa54ff53a,
		0x510e527f,
		0x9b05688c,
		0x1f83d9ab,
		0x5be0cd19
	}

	for Index = 1, #Content, 64 do
		Digestblock(Content, Index, Base)
	end

	for Index, Value in Base do
		Hash[Index] = ProcessNumber(Value, 4)
	end

	return string.gsub(table.concat(Hash), ".", function(Character)
		return string.format("%02x", string.byte(Character))
	end)
end