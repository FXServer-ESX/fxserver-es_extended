# ESX 2

### Sill looking for old version ? => https://github.com/ESX-Org/es_extended/tree/v1-final

# Table of Contents

1. [Installation](#install)
2. [Modules](#modules)
3. [Changelog](#changelog)
4. [Module Examples](#examples)
   1. [Menu](#examples-menu)
   2. [Command](#examples-command)
5. [Want to Contribute?](#contributions)

## Installation <a name="install"></a>

### Requirements:

- An installed MariaDB server (we will not support MySQL).
- [Async script by ESX-Framework](https://github.com/esx-framework/async)
- [MySQL-Async by brouznouf](https://github.com/brouznouf/fivem-mysql-async)
- [Node.Js 10+](https://nodejs.org/en/)

### How to Install:
* Grab the resource, install it as usual (place it in the `/resource` subfolder of your FxServer).
* Open a cmd in the `es_extended` resource.
* Type `npm i` or `yarn` in-order-to install dependents packages.
* Copy the part of the `server.cfg` sample and paste it to yours.
### Server.cfg sample

```bash
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

ensure yarn

ensure mysql-async
ensure cron

ensure es_extended # Will now auto-generate fxmanifest.lua to prevent platform-dependant behavior, will prompt you to type ensure es_extended in console when fxmanifest has changed. To save some typing, uncomment below lines

# stop es_extended
# start es_extended

# REQUIRED
# Add permission for es_extended to execute ACL commands
add_ace resource.es_extended command.add_ace allow
add_ace resource.es_extended command.remove_principal allow
add_ace resource.es_extended command.add_principal allow
add_ace resource.es_extended command.remove_ace allow
add_ace resource.es_extended command.list_aces allow
add_ace resource.es_extended command.list_principals allow
add_ace resource.es_extended command.remove_aces_for_object allow
```

## Modules <a name="modules"></a>
*_There is no more `esx_` resource on this version. This had been deprecated in favor of modules_*

### How to install a module ?
Grab the module you'd like to install. Paste it in the `es_extended/modules/__user__/` directory and add the module name to the list of the `es_extended/modules/__user__/modules.json` file. `modules.json` file should looks like this :
```json
[
  "module-name-here"
]
```
**__WARNING:__** __The file may not already exists if it's your first installation, just create a file named `modules.json` in the `es_extended/modules/__user__/` directory.__

### What's a module ?
A module is an isolated bloc that work independently from any resources or other module (except the core modules provided by esx)

### How does modules work ?
Modules are composed of three parts (not mandatory, you can only use of of these) :
* client - handle all client logic (as usual)
* server - handle all server logic (as usual)
* shared - handle both logic

Each part are again divided in three parts in-order-to make things clearer :
* main.lua : responsible of importing needed core modules and managing the module state. (control flow)
* events.lua : responsible of handling events (the code to execute when an event is received)
* module.lua : see this one as all the functions that would be useful to your module.

### Why is it better ?
For a better and cleaner architecture it's obviously better to have a pattern already set. You'll end up with organized files and modules.

Another thing is the performance, so far, it's more optimized to work this way.

## Changelog <a name="changelog"></a>

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

## Module Examples <a name="examples"></a>

### [How to create and use menus <a name="examples-menu"></a>](https://github.com/ESX-Framework/es_extended/tree/develop/modules/__examples__/menu/)

![Menu](https://i.snipboard.io/tF8AcT.jpg)

### [How to create basic command <a name="examples-command"></a>](https://github.com/ESX-Framework/es_extended/tree/develop/modules/__examples__/commands/)

### More to come...

## Want to contribute? <a name="contributions"></a>

Take a look at our [Esx Contributing Guide](CONTRIBUTING.md) to get familiar with the project and the guideliness.