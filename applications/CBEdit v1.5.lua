--------Библиотеки---------
local component = require("component")
local gpu = component.gpu
local term = require("term") 
local event = require("event")
---------------------------------
local ContextON = false
local blue = true
local red, black = false
local xSize, ySize = gpu.getResolution()
local function menu() -- Создаём меню
  for x = 1, xSize do 
    gpu.setForeground(0x403e3e) 
    gpu.fill(x,1,1,1,"█") 
  end  
  gpu.setForeground(0xeb0707)
  gpu.setBackground(0x403e3e)
  gpu.set(xSize, 1, "X")
  gpu.setForeground(0xFFFFFF)
  gpu.set(1, 1, "Меню")
  gpu.set((xSize/2)-11, 1, "CBEdit v1.5") 
end
local function contextShow()
  for y = 2, 8 do
    for x = 1, 20 do
      gpu.setForeground(0xb5acac)      
      gpu.fill(x,y,1,1,"█")
    end
  end
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
  for y = 2, 8 do
    for x = 1, 20 do
      gpu.setForeground(0xFFFFFF)      
      gpu.fill(x,y,1,1,"█")
    end
  end 
  ContextON = false
end
gpu.setBackground(0xFFFFFF) --ставим белый фон
term.clear() --очищаем экран
menu()
while true do -- запускаем бесконечный цикл
local e = { event.pull() }
--[[
e[1] - event
e[2] - ID монитора
e[3] - X
e[4] - Y
e[5] - нажатая кнопка
e[6] - имя игрока
]]
if(e[1] == "touch" and ContextON == true and e[3] <= 20 and e[4] == 2 and e[5] == 0) then --Если выбран первый пункт в контекстном меню
contextHide() -- выключаем контекстное меню
gpu.setBackground(0xFFFFFF) --ставим белый фон
term.clear() --очищаем экран
menu() -- вызываем меню
elseif(e[1] == "touch" and ContextON == true and e[3] <= 20 and e[4] == 3 and e[5] == 0) then
break
elseif(e[1] == "touch" and ContextON == true and e[3] <= 20 and e[4] == 5 and e[5] == 0) then
red = true
black = false
blue = false
contextHide()
elseif(e[1] == "touch" and ContextON == true and e[3] <= 20 and e[4] == 6 and e[5] == 0) then
blue = true
red = false
black = false
contextHide()
elseif(e[1] == "touch" and ContextON == true and e[3] <= 20 and e[4] == 7 and e[5] == 0) then
black = true
red = false
blue = false
contextHide()
elseif(e[1] == "drag" and e[5] == 0 and e[4] > 1 or e[1] == "touch" and e[5] == 0 and e[4] > 1) then -- проверяем на то, нажата или зажата ли мышка
if(red == true) then
if(ContextON == true and e[3] <= 20 and e[4] > 8) then
gpu.setForeground(0xff0000) -- делаем красным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ 
elseif(ContextON == true and e[4] <= 8 and e[3] > 20) then
gpu.setForeground(0xff0000) -- делаем красным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
elseif(ContextON == true and e[4] > 8 and e[3] > 20) then
gpu.setForeground(0xff0000) -- делаем красным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
elseif(ContextON == false) then
gpu.setForeground(0xff0000) -- делаем красным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
end
elseif(blue == true) then
if(ContextON == true and e[3] <= 20 and e[4] > 8) then
gpu.setForeground(0x0000ff) -- делаем синим gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ 
elseif(ContextON == true and e[4] <= 8 and e[3] > 20) then
gpu.setForeground(0x0000ff) -- делаем синим gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
elseif(ContextON == true and e[4] > 8 and e[3] > 20) then
gpu.setForeground(0x0000ff) -- делаем синим gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
elseif(ContextON == false) then
gpu.setForeground(0x0000FF) -- делаем синим gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
end
elseif(black == true) then
if(ContextON == true and e[3] <= 20 and e[4] > 8) then
gpu.setForeground(0x000000) -- делаем чёрным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ 
elseif(ContextON == true and e[4] <= 8 and e[3] > 20) then
gpu.setForeground(0x000000) -- делаем чёрным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
elseif(ContextON == true and e[4] > 8 and e[3] > 20) then
gpu.setForeground(0x000000) -- делаем чёрным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
elseif(ContextON == false) then
gpu.setForeground(0x000000) -- делаем чёрным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1,"█") -- прорисовываем символ
end
end
elseif(act == "touch" and e[5] == 1 and e[4] > 1 or act == "drag" and e[5] == 1 and e[4] > 1) then -- проверяем на то, нажата или зажата правая кнопка
if(ContextON == true and e[3] <= 20 and e[4] > 8) then
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1," ")
elseif(ContextON == true and e[4] <= 8 and e[3] > 20) then
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1," ")
elseif(ContextON == true and e[4] > 8 and e[3] > 20) then
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1," ")
elseif(ContextON == false) then
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0xFFFFFF)
gpu.fill(e[3],e[4],1,1," ")
end
elseif(e[1] == "key_down" and e[3] == 1057 or e[3] == 67) then -- если нажата комбинация клавиш shift+c
contextHide() -- выключаем контекстное меню, если оно было включено
gpu.setBackground(0xFFFFFF) --ставим белый фон
term.clear() --очищаем экран
menu() -- вызываем меню
elseif(e[1] == "touch" and e[3] <= 4 and e[4] == 1) then
if(ContextON == false) then
contextShow()
else
contextHide()
end
elseif(e[1] == "touch" and e[3] == xSize and e[4] == 1) then --если была нажата кнопка "X"
break --останавливаем цикл
end
end
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF) --делаем всё, как обычно 
term.clear()
print("Спасибо за использование программы CBEdit v1.5 by SergeyZet1!")
os.sleep(2)
term.clear()
