-------------Библиотеки------------
local component = require("component")
local gpu = component.gpu
local term = require("term") 
local event = require("event")
------------------------------------
local ContextON = false
local CurrentColor = 0x0000FF
local xSize, ySize = gpu.getResolution()
local CoordsButton = {
  {20, 2},
  {20, 3},
  {20, 5},
  {20, 6},
  {20, 7}
}
local function menu()
  gpu.setBackground(0x403e3e) 
  gpu.fill(1,1,xSize,1," ") 
  gpu.setForeground(0xeb0707)
  gpu.setBackground(0x403e3e)
  gpu.set(xSize, 1, "X")
  gpu.setForeground(0xFFFFFF)
  gpu.set(1, 1, "Меню")
  gpu.set((xSize/2)-11, 1, "CBEdit v1.5") 
end
local function contextShow()
  gpu.setBackground(0xb5acac)      
  gpu.fill(1,2,20,7," ")
  gpu.setForeground(0x000000)
  gpu.setBackground(0xb5acac)
  gpu.set(1,2,"Очистить поле")
  gpu.set(1,3,"Выйти из программы")
  gpu.set(1,4,"------------------")
  gpu.set(1,5,"Красный цвет")
  gpu.set(1,6,"Синий цвет")
  gpu.set(1,7,"Чёрный цвет")
  gpu.set(1,8,"------------------")
  ContextON = true
end
local function contextHide()
  gpu.setBackground(0xFFFFFF)      
  gpu.fill(1,2,20,7," ")
  ContextON = false
end
local function contextAct(num)
  if(num == 1) then
    contextHide() 
    gpu.setBackground(0xFFFFFF)
    term.clear()
    menu() 
  elseif(num == 3) then
    CurrentColor = 0xff0000
    contextHide()
  elseif(num == 4) then
    CurrentColor = 0x0000FF
    contextHide()
  elseif(num == 5) then
    CurrentColor = 0x000000
    contextHide()
  end
end
local function contextCheck(x,y)
  if(x <= CoordsButton[1][1] and y == CoordsButton[1][2]) then return contextAct(1) end
  if(x <= CoordsButton[2][1] and y == CoordsButton[2][2]) then return 2 end
  if(x <= CoordsButton[3][1] and y == CoordsButton[3][2]) then return contextAct(3) end
  if(x <= CoordsButton[4][1] and y == CoordsButton[4][2]) then return contextAct(4) end
  if(x <= CoordsButton[5][1] and y == CoordsButton[5][2]) then return contextAct(5) end
end
local function IsContext(x,y)
  if(x <= 20 and y >= 8) then return true 
  elseif(x <= 20 and y >= 8) then return true 
  elseif(x <= 20 and y <= 8) then return true
  else return false end
end
gpu.setBackground(0xFFFFFF)
term.clear()
menu()
while true do
local e = { event.pull() }
--[[
e[1] - event
e[2] - ID монитора
e[3] - X
e[4] - Y
e[5] - нажатая кнопка
e[6] - имя игрока
]]
if(e[1] == "touch" and ContextON == true and e[5] == 0) then --Если выбран первый пункт в контекстном меню
  if(contextCheck(e[3],e[4]) == 2) then
    break
  end

elseif(e[1] == "drag" and e[5] == 0 and e[4] > 1 or e[1] == "touch" and e[5] == 0 and e[4] > 1) then -- проверяем на то, нажата или зажата ли мышка
if(ContextON == true and not IsContext(e[3],e[4])) then
gpu.setBackground(CurrentColor) -- делаем цвет, который задан в CurrentColor
gpu.set(e[3],e[4]," ")
elseif(ContextON == false) then
gpu.setBackground(CurrentColor) -- делаем цвет, который задан в CurrentColor
gpu.set(e[3],e[4]," ")
end
elseif(e[1] == "touch" and e[5] == 1 and e[4] > 1 or e[1] == "drag" and e[5] == 1 and e[4] > 1) then -- проверяем на то, нажата или зажата правая кнопка
if(ContextON == true and not IsContext(e[3],e[4])) then
gpu.setBackground(0xFFFFFF)
gpu.set(e[3],e[4]," ")
elseif(ContextON == false) then
gpu.setBackground(0xFFFFFF)
gpu.set(e[3],e[4]," ")
end
elseif(e[1] == "key_down" and e[3] == 1057 or e[3] == 67) then -- если нажата комбинация клавиш shift+c
contextHide()
gpu.setBackground(0xFFFFFF)
term.clear()
menu()
elseif(e[1] == "touch" and e[3] <= 4 and e[4] == 1) then
if(ContextON == false) then
contextShow()
else
contextHide()
end
elseif(e[1] == "touch" and e[3] == xSize and e[4] == 1) then --если была нажата кнопка "X"
break
end
end
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
term.clear()
print("Спасибо за использование программы CBEdit v1.5 by SergeyZet1!")
os.sleep(2)
term.clear()
