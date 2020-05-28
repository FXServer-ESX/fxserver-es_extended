# ESX 2

### Sill looking for old version ? => https://github.com/ESX-Org/es_extended/tree/v1-final

### How to run latest ESX

```
# minimum resources and config to get it working

set mysql_connection_string "mysql://john:smith@localhost/es_extended?charset=utf8mb4"

stop webadmin

ensure mapmanager
ensure chat
ensure spawnmanager
ensure sessionmanager
ensure hardcap
ensure rconlog
ensure baseevents

ensure mysql-async
ensure cron
ensure skinchanger

ensure es_extended
```



### Changelog

```
- Switched to a module-based single resource for ease of use and performance
- Performance improvements
- Split all base functionnalities into their own module
- Module can either encapsulate its own functionality or declare global stuff
- Loading modules via method M('themodule') ensure correct loading order of modules
- Automated database schema generation (RIP SQL files everywhere)
- Database schema can also be expanded by other modules
- Custom event system to avoid serialization of event data and cross-resource communication, that make it possible to pass metatables through these events (You can still use TriggerEvent and such to escape that thing)
- xPlayer fully customizable without rewriting core resources (Hello second job, faction system and such...)
- Added some modules to optimize common things like input, marker and static npc management
- Extend base lua functionnality when appropriate via module. example: table.indexOf
- OOP System based on http://lua-users.org/wiki/InheritanceTutorial and improved
- Neat menu API
- Open as many pages as you want in single NUI frame with Frame API
- EventEmitter class
- WIP rewrite of well-known datastore / inventory / account stuff
```

### Code examples


```lua
-- Menu

M('ui.menu') -- This module provides global Menu factory method

local menu = Menu:create('test', {
  title = 'Test menu',
  float = 'top|left',
  items = {
    {name = 'a', label = 'Fufu c\'est ma bro', type = 'slider'},
    {name = 'b', label = 'Fuck that shit',     type = 'check'},
    {name = 'c', label = 'Fuck that shit',     type = 'text'},
    {name = 'd', label = 'Lorem ipsum'},
    {name = 'e', label = 'Submit',             type = 'button'},
  }
})

menu:on('ready', function()
  menu.items[1].label = 'TEST';-- label changed instantly in webview
end)

menu:on('item.change', function(item, prop, val, index)

  if (item.name == 'a') and (prop == 'value') then

    item.label = 'Dynamic label ' .. tostring(val);

  end

  if (item.name == 'b') and (prop == 'value') then

    local c = table.find(menu.items, function(e) return e.name == 'c' end)

    c.value = 'Dynamic text ' .. tostring(val);

  end

end)

menu:on('item.click', function(item, index)
  print('index', index)
end)
```


![Menu](https://cdn.discordapp.com/attachments/711547420479193088/714823698061721630/unknown.png)

```lua
-- DataStore

M('datastore')

on('esx:db:ready', function()

  local ds = DataStore:create('test', true, {sample = 'data'}) -- name, shared, initial data

  ds:on('save', function()
    print(ds.name .. ' saved => ' .. json.encode(ds:get()))
  end)

  ds:on('ready', function()

    ds:set('foo', 'bar')

    ds:save(function()
      print('callbacks also')
    end)

  end)

end)
```

```lua
-- Here is how datastore schema is declared, no need to feed some SQL file

M('events')

on('esx:db:init', function(initTable, extendTable)

  initTable('datastores', 'name', {
    {name = 'name',  type = 'VARCHAR',  length = 255, default = nil,    extra = 'NOT NULL'},
    {name = 'owner', type = 'VARCHAR',  length = 64,  default = 'NULL', extra = nil},
    {name = 'data',  type = 'LONGTEXT', length = nil, default = nil,    extra = nil},
  })

end)
```

```lua
-- Want to create faction system ?

M('player')

xPlayer.createDBAccessor('faction', {name = 'faction', type = 'VARCHAR', length = 64, default = 'gang.ballas', extra = nil})

-- Now any player (which is instance of xPlayer) have the following methods
-- Also user table has now a faction column added automatically

local player = xPlayer:fromId(2)

print(player:getFaction())

player:setFaction('another.faction')

player:save()
```

```lua
-- I want to store JSON :(
-- No problem

xPlayer.createDBAccessor('someData', {name = 'some_data', type = 'TEXT', length = nil, default = '{}', extra = nil}, json.encode, json.decode)
```

```lua
-- I want to store WHATEVER (comma-separated list for example) :(
-- No problem

M('string')

xPlayer.createDBAccessor(
  'someWeirdData',
  {name = 'some_weird_data', type = 'TEXT', length = nil, default = '1,2,3,4,5', extra = nil},
  function(x) -- encode
    return table.concat(x, ',')
  end,
  function(x) -- decode
    return string.split(x, ',')
  end
)
```
