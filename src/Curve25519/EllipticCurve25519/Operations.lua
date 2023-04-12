-- Custom Bit32 library to fit Curve25519's functionality.

function ToBinary(Input)
	if Input < 0 then
		return ToBinary(Not(math.abs(Input)) + 1)
	end

	local Output, Index = {}, 1

	while (Input > 0) do
		local Remainder = Input % 2

		Output[Index] = if Remainder == 1 then 1 else 0
		Input = (Input - Remainder) * 0.5
		Index += 1
	end

	return Output
end

function ToTernaryNumber(Input)
	local Output, Cache = 0, 1

	for Index = 1, #Input do
		Output += Input[Index] * Cache
		Cache *= 2
	end

	return Output
end

function Operation(X, Y, Callback)
	local Z, W = ToBinary(X), ToBinary(Y)
	local Output, J, K = {}, {}, {}

	if #Z > #W then
		J, K = Z, W
	else
		J, K = W, Z
	end

	for Index = #K + 1, #J do
		K[Index] = 0
	end

	for Index = 1, math.max(#Z, #W) do
		Output[Index] = Callback(Z[Index], W[Index])
	end

	return ToTernaryNumber(Output)
end

function Not(Input)
	local Output = ToBinary(Input)

	for Index = 1, math.max(#Output, 32) do
		Output[Index] = if Output[Index] == 1 then 0 else 1
	end

	return ToTernaryNumber(Output)
end

return {
	["NOT"] = Not,

	["AND"] = function(X, Y)
		return Operation(X, Y, function(x, y)
			return if (x == 0) or (y == 0) then 0 else 1
		end)
	end,
	["OR"] = function(X, Y)
		return Operation(X, Y, function(x, y)
			return if (x == 0) and (y == 0) then 0 else 1
		end)
	end,
	["XOR"] = function(X, Y)
		return Operation(X, Y, function(x, y)
			return if (x ~= y) then 1 else 0
		end)
	end,

	["RSHIFT"] = function(x, y)
		return math.floor(x / 2 ^ y)
	end,
	["LSHIFT"] = function(x, y)
		return x * 2 ^ y
	end
}