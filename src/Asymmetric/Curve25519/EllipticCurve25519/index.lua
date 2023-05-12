local Operations = require(script.Parent:WaitForChild("Operations"))

local Origin = { 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
local Curve = {0xDB41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

local function Carry25519(Output)
	local Carry
	for Index = 1, 16 do
		Output[Index] += 65536
		Carry = math.floor(Output[Index] / 65536)

		if Index < 16 then
			Output[Index + 1] += Carry - 1
		else
			Output[1] += 38 * (Carry - 1)
		end

		Output[Index] -= Operations.LSHIFT(Carry, 16)
	end
end

local function Select25519(p, q, b)
	local Carry = Operations.NOT(b - 1)

	if Carry == 4294967295 then
		Carry = -1
	end

	local Cache
	for Index = 1, 16 do
		Cache = Operations.AND(Carry, Operations.XOR(p[Index], q[Index]))

		p[Index] = Operations.XOR(p[Index], Cache)
		q[Index] = Operations.XOR(q[Index], Cache)
	end
end

local function Pack25519(Output, Input)
	local Cache, Operator = {}, Input
	local Carry

	Carry25519(Operator)
	Carry25519(Operator)
	Carry25519(Operator)

	for _ = 1, 2 do
		Cache[1] = Operator[1] - 0xffed

		for Index : number = 2, 15 do
			Cache[Index] = Operator[Index] - 0xffff - Operations.AND(Operations.RSHIFT(Cache[Index - 1], 16), 1)
			Cache[Index - 1] = Operations.AND(Cache[Index - 1], 0xffff)
		end

		Cache[16] = Operator[16] - 0x7fff - Operations.AND(Operations.RSHIFT(Cache[15], 16), 1)
		Carry = Operations.AND(Operations.RSHIFT(Cache[16], 16), 1)
		Cache[15] = Operations.AND(Cache[15], 0xffff)

		Select25519(Operator, Cache, 1 - Carry)
	end

	for Index = 1, 16 do
		Output[2 * Index - 1] = Operations.AND(Operator[Index], 0xff)
		Output[2 * Index] = Operations.RSHIFT(Operator[Index], 8)
	end
end

local function Unpack25519(Output, Input)
	for Index = 1, 16 do
		Output[Index] = Input[2 * Index - 1] + Operations.LSHIFT(Input[2 * Index], 8)
	end

	Output[16] = Operations.AND(Output[16], 0x7fff)
end

local function Add(Output, A, B)
	for Index = 1, 16 do
		Output[Index] = A[Index] + B[Index]
	end
end

local function Subtract(Output, A, B)
	for Index = 1, 16 do
		Output[Index] = A[Index] - B[Index]
	end
end

local function Multiply(Output, a, b)
	local Cache = table.create(32, 0)

	for Index = 1, 16 do
		for Iterator = 1, 16 do
			Cache[Index + Iterator - 1] += a[Index] * b[Iterator]
		end
	end

	for Index = 1, 15 do
		Cache[Index] += 38 * Cache[Index + 16]
	end

	for Index = 1, 16 do
		Output[Index] = Cache[Index]
	end

	Carry25519(Output)
	Carry25519(Output)
end

local function Square(Output, Input)
	Multiply(Output, Input, Input)
end

local function Inverse25519(Output, Input)
	local Carry = {}

	for Index = 1, 16 do
		Carry[Index] = Input[Index]
	end

	for Index = 253, 0, -1 do
		Square(Carry, Carry)

		if Index ~= 2 and Index ~= 4 then
			Multiply(Carry, Carry, Input)
		end
	end

	for Index = 1, 16 do
		Output[Index] = Carry[Index]
	end
end

local function CryptographicScalarMultiplication(Output, n, p) -- out q[], in n[], in p[]
	local z, x, x16, x32 = n, {}, {}, {}
	local a = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local b = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local c = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local d = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local e = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local f = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

	z[32] = Operations.OR(Operations.AND(n[32], 127), 64)
	z[1] = Operations.AND(z[1], 248)

	Unpack25519(x, p)

	for Index = 1, 16 do
		b[Index] = x[Index]
	end

	a[1], d[1] = 1, 1

	for Index = 254, 0, -1 do
		local Remainder = Operations.AND(Operations.RSHIFT(z[Operations.RSHIFT(Index, 3) + 1], Operations.AND(Index, 7)), 1)

		Select25519(a, b, Remainder)
		Select25519(c, d, Remainder)

		Add(e, a, c)
		Subtract(a, a, c)
		Add(c, b, d)
		Subtract(b, b, d)

		Square(d, e)
		Square(f, a)

		Multiply(a, c, a)
		Multiply(c, b, e)

		Add(e, a, c)
		Subtract(a, a, c)

		Square(b, a)
		Subtract(c, d, f)

		Multiply(a, c, Curve)
		Add(a, a, d)

		Multiply(c, c, a)
		Multiply(a, d, f)
		Multiply(d, b, x)

		Square(b, e)

		Select25519(a, b, Remainder)
		Select25519(c, d, Remainder)
	end

	for Index = 1, 16 do
		x[Index + 16] = a[Index]
		x[Index + 32] = c[Index]
		x[Index + 48] = b[Index]
		x[Index + 64] = d[Index]
	end
	
	for Index = 1, #x do
		if Index > 16 then
			x16[Index - 16] = x[Index]
		end
		if Index > 32 then
			x32[Index - 32] = x[Index]
		end
	end

	Inverse25519(x32, x32)
	Multiply(x16, x16, x32)
	Pack25519(Output, x16)
end

return {
	["ScalarMultiplication"] = CryptographicScalarMultiplication,
	["ScalarMultiplicationBase"] = function(Output, Input)
		return CryptographicScalarMultiplication(Output, Input, Origin)
	end
}