-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code

module.Ready              = false
module.IsPaused           = false
module.Frame              = nil
module.RegisteredElements = {}

module.SetDisplay = function(opacity)

	module.Frame:postMessage({
		action  = 'setHUDDisplay',
		opacity = opacity
  })

end

module.RegisterElement = function(name, index, priority, html, data)
	local found = false

	for i=1, #module.RegisteredElements, 1 do
		if module.RegisteredElements[i] == name then
			found = true
			break
		end
	end

	if found then
		return
	end

	table.insert(module.RegisteredElements, name)

  module.Frame:postMessage({
		action    = 'insertHUDElement',
		name      = name,
		index     = index,
		priority  = priority,
		html      = html,
		data      = data
	})

  module.UpdateElement(name, data)

end

module.RemoveElement = function(name)

  for i=1, #module.RegisteredElements, 1 do
		if module.RegisteredElements[i] == name then
			table.remove(module.RegisteredElements, i)
			break
		end
	end

	module.Frame:postMessage({
		action    = 'deleteHUDElement',
		name      = name
  })

end

module.UpdateElement = function(name, data)
	module.Frame:postMessage({
		action = 'updateHUDElement',
		name   = name,
		data   = data
	})
end
