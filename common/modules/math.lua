ESX.Math = {}

ESX.Math.Round = function(value, numDecimalPlaces)
	if (numDecimalPlaces) then
		return math.floor((value * 10^numDecimalPlaces) + 0.5) / (10^numDecimalPlaces)
	else
		return math.floor(value+0.5)
	end
end

-- credit http://richard.warburton.it
ESX.Math.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end

ESX.Math.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end
