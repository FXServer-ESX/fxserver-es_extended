onRequest('fuel:payme', function(source, cb) 
    local player = Player.fromId(source)
    print(player)
    cb(true)
    --Waiting for money module.
end)