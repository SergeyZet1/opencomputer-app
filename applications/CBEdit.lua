--------Библиотеки, ёпта---------
local component = require("component")
local gpu = component.gpu
local term = require("term") 
local event = require("event")
----------------------------------
local xSize, ySize = gpu.getResolution()
local function menu() -- создаём функцию, создающию меню
  for y = 1, 2 do -- запускаем цикл с координатой y
    for x = 1, xSize do -- запускаем ещё один цикл с координатой x
      gpu.setForeground(0x403e3e) --делаем серым gpu.fill
      gpu.fill(x,y,1,1,"█") --создаём символ █
    end 
  end 
  term.setCursor(xSize-6,1) --переводим курсор на край экрана и отнимаем 6
  term.write("Закрыть") -- делаем кнопку
end
gpu.setBackground(0xFFFFFF) --ставим белый фон
term.clear() --очищаем экран, дабы не было всякой поебени
menu()
while true do -- запускаем бесконечный цикл
local act,ID, X, Y, button = event.pull(act,ID,X,Y) -- создаём локальные переменные act - эвент, x и y координату
if(act == "drag" and button == 0 and Y > 2 or act == "touch" and button == 0 and Y > 2) then -- проверяем на то, нажата или зажата ли мышка
gpu.setForeground(0x0000FF) -- делаем синим gpu.fill
gpu.fill(X,Y,1,1,"X") -- прорисовываем крестик
elseif(act == "touch" and button == 1 and Y > 2 or act == "drag" and button == 1 and Y > 2) then -- проверяем на то, нажата или зажата правая кнопка
gpu.setForeground(0xFFFFFF)
gpu.fill(X,Y,1,1," ")
elseif(act == "touch" and X >= xSize-6 and Y == 1) then --если была нажата кнопка
break --останавливаем цикл
end
end
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF) --делаем всё, как обычно 
term.clear() --очищаем экран
print("Спасибо за использование программы CBEdit v1.1 by SergeyZet1!") --и благодарим их за использование
os.sleep(2) --делаем задержку в две секунды, чтобы они успели прочитать
term.clear() --после чего снова очищаем экран
