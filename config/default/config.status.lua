Config.Modules.Status = {
  StatusMax          = 100,
  TickTime           = 1000,
  UpdateInterval     = 20,
  NotificationValues = {0,1,2,3,4,5,6,7,8,9,10,15,20,25,50,75,100},
  DefaultValues      = {0,0,0,100,100},
  StatusInfo         = {
    ["hunger"] = {
      default  = 100,
      color    = "orange",
      iconType = "fontawesome",
      icon     = "fa-hamburger",
      fadeType = "desc",
      NotificationValues = {0,1,2,3,4,5,6,7,8,9,10,15,20,25,50,75,100}
    },
    ["thirst"] = {
      default  = 100,
      color    = "cyan",
      iconType = "fontawesome",
      icon     = "fa-tint",
      fadeType = "desc",
      NotificationValues = {0,1,2,3,4,5,6,7,8,9,10,15,20,25,50,75,100}
    },
    ["drugs"] = {
      default  = 0,
      color    = "green",
      iconType = "fontawesome",
      icon     = "fa-cannabis",
      fadeType = "asc",
      NotificationValues = {0,1,2,3,4,5,6,7,8,9,10,15,20,25,50,75,100}
    },
    ["drunk"] = {
      default  = 0,
      color    = "purple",
      iconType = "fontawesome",
      icon     = "fa-glass-martini-alt",
      fadeType = "asc",
      NotificationValues = {0,1,2,3,4,5,6,7,8,9,10,15,20,25,50,75,100}
    },
    ["stress"] = {
      default  = 0,
      color    = "pink",
      iconType = "fontawesome",
      icon     = "fa-brain",
      fadeType = "asc",
      NotificationValues = {50,75,100}
    }
  }
}
