-----------------------Библиотеки-----------------------
local component = require("component")
local event = require("event")
---------------------------------------------------------
if(component.isAvailable("motion_sensor") == false) then
print("Серёга, хуйня какая-то, подключи ёбаный датчик движения!")
return 0
end
if(component.isAvailable("redstone") == false) then
print("Серёга, сука, почему ты красный камень забыл подключить?")
return 0
end
local rs = component.redstone
local msensor = component.motion_sensor
msensor.setSensitivity(1)
require("term").clear()
print("OpenDoor v1.0 готов к работе!")
while true do
  rs.setOutput(2, 0)
  local act, _, x, y, z, player = event.pull()
  if(act == "motion" and player == "ImReyzzz") then
    print("Рейз, блять, почему ты не оглядываешься по сторонам? Открываю люк!")
    rs.setOutput(2, 15)
    os.sleep(3)
  elseif(act == "motion" and player == "Lucky_Kotik") then
    print("Лаки, сука, почему такой невнимательный? Открываю люк!")
    rs.setOutput(2, 15)
    os.sleep(3)
  elseif(act == "motion") then
    print(player .. " упал в дыру! Открываю люк!")
    rs.setOutput(2, 15)
    os.sleep(3)
  end
end