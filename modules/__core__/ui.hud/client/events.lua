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

M('events')

local chunks = {}

RegisterNUICallback('__chunk', function(data, cb)

	chunks[data.id] = chunks[data.id] or ''
	chunks[data.id] = chunks[data.id] .. data.chunk

	if data['end'] then
		local msg = json.decode(chunks[data.id])
		emit(data.__namespace .. ':message:' .. data.__type, msg)
		chunks[data.id] = nil
	end

  cb('')

end)

RegisterNUICallback('nui_ready', function(data, cb)
  module.Ready = true
  emit('esx:nui:ready')
  cb('')
end)

RegisterNUICallback('frame_load', function(data, cb)
  emit('esx:frame:load', data.name)
  cb('')
end)

RegisterNUICallback('frame_message', function(data, cb)
  
  local subscribed = false

  emit('esx:frame:message', data.name, data.msg, function()
    subscribed = true
    return cb
  end)

  if not subscribed then
    cb('')
  end

end)

on('esx:frame:load', function(name)
  
  local frame = module.Frames[name]

  if frame == nil then

    print('error, frame [' .. name .. '] not found')

  else

    frame:emit('load')

  end

end)

-- If you call handleCallback, esx will not call the nui callback automatically
-- Instead it will return it from that handleCallback function so you can call it whenever you want
-- If you want to make use of this behavior, it is mandatory to call handleCallback synchronously
-- When you have the callback returned by handleCallback, you can wall it whenever you want tough
-- Because it will be marked as 'subscribed' and esx will never call it by itself

on('esx:frame:message', function(name, msg, handleCallback)

  if name == '__root__' then

    emit('esx:hud:message', msg, handleCallback)

  else

    local frame = module.Frames[name]

    if frame == nil then
      print('error, frame [' .. name .. '] not found')
    else
      if not(frame.destroyed) then
        frame:emit('message', msg, handleCallback)
      end
    end

  end

end)
