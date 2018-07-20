------------Библиотеки--------------------
local component = require("component")
local event = require("event")
------------------------------------------
require("term").clear()
local xSize, ySize = component.gpu.getResolution()
local port = 415
if(component.isAvailable("modem") == false or component.modem.isWireless() == false) then
  print("У вас нету беспроводной сетевой карты!")
  return 0
end
local thread = require("thread")
local modem = component.modem
local cursorX, cursorY = 1, 1
modem.open(port)
modem.setStrength(70000)
print("Введите ваш ник: ")
local yournick = require("term").read()
tostring(yournick)
require("term").clear()
local function send(string)
  modem.broadcast(port,string.sub(yournick,0,string.len(yournick) - 1),"WirelessMSG_message",string)
  require("computer").beep(1500)
end
local function wait()
  while true do
  require("term").setCursor(1,ySize)
  require("term").clearLine()
  local msg = require("term").read(_,false)
  tostring(msg)
  send(tostring(msg))
  require("term").setCursor(1, cursorY)
  cursorY = cursorY + 1
  if(cursorY == ySize) then
    require("term").clear()
    cursorY = 1
    require("term").setCursor(1,cursorY)
  end
  print(string.sub(yournick,0,string.len(yournick) - 1) .. "(вы)" .. ": " .. msg)
  require("term").setCursor(1, ySize)
  end  
end
local function waitMSG()
  while true do
    local act, receiver, sender, portReceive, distance, nick, type, msg = event.pull()
    if(act == "modem_message") then
      if(portReceive == port) then
        if(type == "WirelessMSG_message") then
          require("term").setCursor(1, cursorY)
          cursorY = cursorY + 1
          if(cursorY == ySize) then
            require("term").clear()
            cursorY = 1
            require("term").setCursor(1,cursorY)
          end
          print(nick .. "(" .. string.sub (sender, 0, 3) .. ")" .. ": " .. msg)
          require("term").setCursor(1, ySize)
          require("computer").beep(1500)
        end
      end
    end
  end
end
thread.create(waitMSG)
thread.create(wait)
while true do
os.sleep(0.1)
end



