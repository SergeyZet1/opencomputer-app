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
  {20, 2, "Очистить поле"},
  {20, 3, "Выйти из программы"},
  {20, 5, "Красный цвет"},
  {20, 6, "Синий цвет"},
  {20, 7, "Чёрный цвет"},
  {20, 8, "Жёлтый цвет"}
} -- координаты кнопок
local Buffer = {} --буфер (для того, чтобы не исчезало то, что мы нарисовали в левом верхнем углу)
local Buttons_MaxY = CoordsButton[#CoordsButton][2] --самое последнее значение Y
--------------------------------------------------------------------------------------------------------
local function draw(x,y,color)
  gpu.setBackground(color)
  gpu.set(x,y," ")
end
------------------------------Функции, связанные с контекстом-------------------------------------------
local function menu()
  gpu.setBackground(0x403e3e) 
  gpu.fill(1,1,xSize,1," ") 
  gpu.setForeground(0xeb0707)
  gpu.setBackground(0x403e3e)
  gpu.set(xSize, 1, "X")
  gpu.setForeground(0xFFFFFF)
  gpu.set(1, 1, "Меню")
  gpu.set((xSize/2)-11, 1, "CBEdit v1.8") 
end
local function contextShow()
  for y = 2, Buttons_MaxY+1 do
  	Buffer[y] = {}
  	for x = 1, 20 do 		
  		local _,_,bg = gpu.get(x,y)
  		Buffer[y][x] = bg
  	end
  end
  gpu.setBackground(0xb5acac)      
  gpu.fill(1,2,20,Buttons_MaxY," ")
  gpu.setForeground(0x000000)
  gpu.setBackground(0xb5acac)
  for i = 1, #CoordsButton do
    gpu.set(1,CoordsButton[i][2],CoordsButton[i][3])
  end
  gpu.set(1,4,"------------------")
  gpu.set(1,Buttons_MaxY+1,"------------------")
  ContextON = true
end
local function contextHide()
  for y = 2, Buttons_MaxY+1 do
  	for x = 1, 20 do
  		draw(x,y,Buffer[y][x])
  	end
  end
  --gpu.setBackground(0xFFFFFF)      
  --gpu.fill(1,2,20,Buttons_MaxY," ")
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
  elseif(num == 6) then
    CurrentColor = 0xffff00
    contextHide()
  end
end
local function contextCheck(x,y)
  for i = 1, #CoordsButton do
    if(x <= CoordsButton[2][1] and y == CoordsButton[2][2]) then return 2
    elseif(x <= CoordsButton[i][1] and y == CoordsButton[i][2]) then return contextAct(i) end
  end
end
local function IsContext(x,y)
  if(x <= 20 and y <= Buttons_MaxY+1 and y ~= 1) then return true 
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
  if(e[1] == "touch" and ContextON == true and e[5] == 0 and e[4] ~= 1) then --Если выбран первый пункт в контекстном меню
    local result = contextCheck(e[3],e[4])
    if(result) == 2 then break end
  elseif(e[1] == "drag" and e[5] == 0 and e[4] > 1 or e[1] == "touch" and e[5] == 0 and e[4] > 1) then -- проверяем на то, нажата или зажата ли мышка
    if(ContextON == true and not IsContext(e[3],e[4])) then
      draw(e[3],e[4],CurrentColor)
    elseif(ContextON == false) then
      draw(e[3],e[4],CurrentColor)
    end
  elseif(e[1] == "touch" and e[5] == 1 and e[4] > 1 or e[1] == "drag" and e[5] == 1 and e[4] > 1) then -- проверяем на то, нажата или зажата правая кнопка
    if(ContextON == true and not IsContext(e[3],e[4])) then
      draw(e[3],e[4],0xFFFFFF)
    elseif(ContextON == false) then
      draw(e[3],e[4],0xFFFFFF)
    end
  elseif(e[1] == "key_down" and e[3] == 1057 or e[3] == 67) then -- если нажата комбинация клавиш shift+c
    contextHide()
    gpu.setBackground(0xFFFFFF)
    term.clear()
    menu()
  elseif(e[1] == "touch" and e[3] <= 4 and e[4] == 1 and e[5] == 0) then
    if ContextON == true then
      contextHide()
    else
      contextShow()
    end
  elseif(e[1] == "touch" and e[3] == xSize and e[4] == 1) then --если была нажата кнопка "X"
    break
  end
end
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
term.clear()
print("Спасибо за использование программы CBEdit v1.8 by SergeyZet1!")
os.sleep(2)
term.clear()
