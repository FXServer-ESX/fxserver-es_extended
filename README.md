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
```

