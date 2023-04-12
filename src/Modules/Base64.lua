local Library = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local Module = {}

function Module.Encode(Data)
	local InputType = type(Data)
	assert(InputType == "string", string.format("Expected type \"string\" for argument #1 of \"Base64:Decode()\". Recieved type \"%s\".", InputType))

	return (string.gsub(string.gsub(Data, ".", function(Chunk)
		local Result, Byte = "", string.byte(Chunk)

		for Index = 8, 1, -1 do
			Result ..= if Byte % 2 ^ Index - Byte % 2 ^ (Index - 1) > 0 then '1' else '0'
		end

		return Result

	end) .. "0000", "%d%d%d?%d?%d?%d?", function(Chunk)
		if #Chunk < 6 then return "" end

		local Count = 0

		for Index = 1, 6 do
			Count += if string.sub(Chunk, Index, Index) == "1" then 2 ^ (6 - Index) else 0
		end

		return string.sub(Library, Count + 1, Count + 1)

	end) .. ({ "", "==", "=" })[string.len(Data) % 3 + 1])
end

function Module.Decode(Data)
	local InputType = type(Data)
	assert(InputType == "string", string.format("Expected type \"string\" for argument #1 of \"Base64:Decode()\". Recieved type \"%s\".", InputType))

	return string.gsub(string.gsub(string.gsub(Data, "[^" .. Library .. "=]", ""), '.', function(Chunk)
		if Chunk == "=" then
			return ""
		end

		local Result, Found = "", string.find(Library, Chunk) - 1

		for Index = 6, 1, -1 do
			Result ..= if Found % 2 ^ Index - Found % 2 ^ (Index - 1) > 0 then "1" else "0"
		end

		return Result

	end), "%d%d%d?%d?%d?%d?%d?%d?", function(Chunk)
		if #Chunk ~= 8 then
			return ""
		end

		local Count = 0

		for Index = 1, 8 do
			Count += if string.sub(Chunk, Index, Index) == "1" then 2 ^ (8 - Index) else 0
		end

		return string.char(Count)
	end)
end

return Module