--------Библиотеки, ёпта---------
local component = require("component")
local gpu = component.gpu
local term = require("term") 
local event = require("event")
---------------------------------
local ContextON = false
local blue = true
local red, black = false
local xSize, ySize = gpu.getResolution()
local function menu() -- создаём функцию, создающую меню
  for x = 1, xSize do -- запускаем ещё один цикл с координатой x
    gpu.setForeground(0x403e3e) --делаем серым gpu.fill
    gpu.fill(x,1,1,1,"█") --создаём символ █
  end  
  gpu.setForeground(0xeb0707)
  gpu.setBackground(0x403e3e)
  gpu.set(xSize, 1, "X") -- делаем кнопку
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
term.clear() --очищаем экран, дабы не было всякой поебени
menu()
while true do -- запускаем бесконечный цикл
local act,ID, X, Y, button = event.pull(act,ID,X,Y) -- создаём локальные переменные act - эвент, x и y координату
if(act == "touch" and ContextON == true and X <= 20 and Y == 2 and button == 0) then --Если выбран первый пункт в контекстном меню
contextHide() -- выключаем контекстное меню
gpu.setBackground(0xFFFFFF) --ставим белый фон
term.clear() --очищаем экран
menu() -- вызываем меню
elseif(act == "touch" and ContextON == true and X <= 20 and Y == 3 and button == 0) then
break
elseif(act == "touch" and ContextON == true and X <= 20 and Y == 5 and button == 0) then
red = true
black = false
blue = false
contextHide()
elseif(act == "touch" and ContextON == true and X <= 20 and Y == 6 and button == 0) then
blue = true
red = false
black = false
contextHide()
elseif(act == "touch" and ContextON == true and X <= 20 and Y == 7 and button == 0) then
black = true
red = false
blue = false
contextHide()
elseif(act == "drag" and button == 0 and Y > 1 or act == "touch" and button == 0 and Y > 1) then -- проверяем на то, нажата или зажата ли мышка
if(red == true) then
if(ContextON == true and X <= 20 and Y > 8) then
gpu.setForeground(0xff0000) -- делаем красным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ 
elseif(ContextON == true and Y <= 8 and X > 20) then
gpu.setForeground(0xff0000) -- делаем красным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
elseif(ContextON == true and Y > 8 and X > 20) then
gpu.setForeground(0xff0000) -- делаем красным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
elseif(ContextON == false) then
gpu.setForeground(0xff0000) -- делаем красным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
end
elseif(blue == true) then
if(ContextON == true and X <= 20 and Y > 8) then
gpu.setForeground(0x0000ff) -- делаем синим gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ 
elseif(ContextON == true and Y <= 8 and X > 20) then
gpu.setForeground(0x0000ff) -- делаем синим gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
elseif(ContextON == true and Y > 8 and X > 20) then
gpu.setForeground(0x0000ff) -- делаем синим gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
elseif(ContextON == false) then
gpu.setForeground(0x0000FF) -- делаем синим gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
end
elseif(black == true) then
if(ContextON == true and X <= 20 and Y > 8) then
gpu.setForeground(0x000000) -- делаем чёрным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ 
elseif(ContextON == true and Y <= 8 and X > 20) then
gpu.setForeground(0x000000) -- делаем чёрным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
elseif(ContextON == true and Y > 8 and X > 20) then
gpu.setForeground(0x000000) -- делаем чёрным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
elseif(ContextON == false) then
gpu.setForeground(0x000000) -- делаем чёрным gpu.fill
gpu.setBackground(0xFFFFFF)
gpu.fill(X,Y,1,1,"█") -- прорисовываем символ
end
end
elseif(act == "touch" and button == 1 and Y > 1 or act == "drag" and button == 1 and Y > 1) then -- проверяем на то, нажата или зажата правая кнопка
if(ContextON == true and X <= 20 and Y > 8) then
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0xFFFFFF)
gpu.fill(X,Y,1,1," ")
elseif(ContextON == true and Y <= 8 and X > 20) then
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0xFFFFFF)
gpu.fill(X,Y,1,1," ")
elseif(ContextON == true and Y > 8 and X > 20) then
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0xFFFFFF)
gpu.fill(X,Y,1,1," ")
elseif(ContextON == false) then
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0xFFFFFF)
gpu.fill(X,Y,1,1," ")
end
elseif(act == "key_down" and X == 1057 or X == 67) then -- если нажата комбинация клавиш shift+c
contextHide() -- выключаем контекстное меню, если оно было включено
gpu.setBackground(0xFFFFFF) --ставим белый фон
term.clear() --очищаем экран
menu() -- вызываем меню
elseif(act == "touch" and X <= 4 and Y == 1) then
if(ContextON == false) then
contextShow()
else
contextHide()
end
elseif(act == "touch" and X == xSize and Y == 1) then --если была нажата кнопка "X"
break --останавливаем цикл
end
end
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF) --делаем всё, как обычно 
term.clear() --очищаем экран
print("Спасибо за использование программы CBEdit v1.5 by SergeyZet1!") --и благодарим их за использование
os.sleep(2) --делаем задержку в две секунды, чтобы они успели прочитать
term.clear() --после чего снова очищаем экран
