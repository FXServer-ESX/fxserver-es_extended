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

local utils = M("utils")

self.Menu = nil

self.CheckIdentity = function()
  request(
    "esx:identity:check",
    function(hasRegistered)
      if not hasRegistered then
        self.OpenMenu()
      end
    end
  )
end

self.OpenMenu = function()
  utils.ui.showNotification(_U('identity_register'))

  self.Menu =
    Menu:create(
    "identity",
    {
      float = "center|middle",
      title = "Create Character",
      items = {
        {name = "firstName", label = "First name", type = "text", placeholder = "John"},
        {name = "lastName", label = "Last name", type = "text", placeholder = "Smith"},
        {name = "dob", label = "Date of birth", type = "text", placeholder = "01/02/1234"},
        {name = "isMale", label = "Male", type = "check", value = true},
        {name = "submit", label = "Submit", type = "button"}
      }
    }
  )

  self.Menu:on(
    "item.change",
    function(item, prop, val, index)
      if (item.name == "isMale") and (prop == "value") then
        if val then
          item.label = "Male"
        else
          item.label = "Female"
        end
      end
    end
  )

  self.Menu:on(
    "item.click",
    function(item, index)
      if item.name == "submit" then
        local props = self.Menu:kvp()

        print(json.encode(props))

        if (props.firstName ~= "") and (props.lastName ~= "") and (props.dob ~= "") then
          emitServer("esx:identity:register", props)

          self.Menu:destroy()
          self.Menu = nil

          utils.ui.showNotification(_U('identity_welcome', props.firstName, props.lastName))
        else
          utils.ui.showNotification(_U('identity_fill_in'))
        end
      end
    end
  )
end
