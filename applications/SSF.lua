------------Библиотеки--------------------
local component = require("component")
local event = require("event")
local shell = require("shell")
local fs = require("filesystem")
------------------------------------------
if(component.isAvailable("modem") == false or component.modem.isWireless() == false) then
  print("У вас нету беспроводной сетевой карты!")
  return 0
end
local modem = component.modem
local port = 515
modem.setStrength(3000)
modem.open(port)
--------------------------------------------------------------------------------------
local function sendFile(name,filePath)
	if not fs.exists(filePath) then return print("Файл не найден!") end
	modem.broadcast(port,"SRF_sendfile_query",fs.name(filePath), name)
	print("Отправляю запрос на сервер " .. name)
	local file = io.open(filePath,"rb")
	local maxPacketSize = modem.maxPacketSize() - 32
	local data
	while true do
		data = file:read(maxPacketSize)
		local e = { event.pull(3, "modem_message") }
		if e[6] == "query_ok" then
			if data then
				modem.broadcast(port,"filesend",data, name)
			else
				break
			end
		elseif not e[1] then
			return print("Отправка файла закончилась неудачей. Сервер не отвечает.")
		end
	end
	file:close()
	modem.broadcast(port, "filesendend", name)
	print("Файл успешно отправлен на сервер " .. name)
end
--------------------------------------------------------------------------------------
local function receiveFile(name,fileName,debug)
	if(string.match(fileName,"/")) then return print("Нельзя вводить каталоги!") end
	fs.makeDirectory("/SSF_files/" .. name)
	local file = io.open("/SSF_files".. "/" .. name .. "/" .. fileName, "w")
	modem.broadcast(port,"SRF_receivefile_query",fileName, name)
	print("Отправляю запрос на сервер " .. name)
	while true do
		
		local e = { event.pull(10,"modem_message") }
		if(e[4] == port and e[6] == "query_error" and e[7] == name) then
			file:close()
			fs.remove("/SSF_files".. "/" .. name .. "/" .. fileName)
			return print("Приём файла " .. fileName .. " от сервера " .. name .. " закончилась с ошибкой. Файл не найден.")
		elseif(e[4] == port and e[6] == "query_ok" and e[7] == name) then
			modem.broadcast(port,"SSF_ok",name)
		elseif(e[4] == port and e[6] == "filesend" and e[8] == name) then
			file:write(e[7])
	  	modem.broadcast(port,"SSF_ok",name)
		elseif(e[4] == port and e[6] == "filesendend" and e[7] == name) then
			file:close()
			return print("Приём файла " .. fileName .. " от сервера " .. name .. " успешно завершён")
		elseif not e[1] then
			file:close()
			fs.remove("/SSF_files".. "/" .. name .. "/" .. fileName)
			return print("Приём файла " .. fileName .. " от сервера " .. name .. " закончилась с ошибкой. Сервер не отвечает.")
		end
	end
end
local args, options = shell.parse(...)
if(args[1] == nil or args[2] == nil) then return print("Введите адрес и путь к файлу (SSF [имя сервера] [файл/путь к нему] [-r - получает файл от сервера])") end
for x, i in pairs(options) do
	if x ~= "r" then return print("Неверный аргумент!") end
end
if not options["r"]  then
	sendFile(args[1],args[2])
elseif options["r"] then
	receiveFile(args[1],args[2])
else return print("Неверный аргумент!") end