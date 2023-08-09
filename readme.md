Installation:

1. Add the line from `qb-core_ITEMS/items.lua` to your QB-Core item list.
2. Add the image in `images` to `qb-inventory/html/images/`

Multiple functions adapted from [qb-ambulancejob](https://github.com/qbcore-framework/qb-ambulancejob)

Add the following events to `qb-ambulancejob/client/wounding.lua`:
```lua
RegisterNetEvent('hospital:client:bleedPlayer', function(level)
    ApplyBleed(level)
end)

RegisterNetEvent('hospital:client:stopBleed', function(level)
    RemoveBleed(level)
end)
```