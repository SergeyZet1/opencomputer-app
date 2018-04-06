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
local function receiveFile(name,fileName,toPath)
	if(fs.isDirectory(fileName)) then return print("Нельзя вводить каталоги!") end
	local path = fs.path(fileName)
	if(toPath) then
		fs.makeDirectory("/SSF_files/" .. name .. "/" .. fs.path(toPath))
	else
		fs.makeDirectory("/SSF_files/" .. name .. "/" .. path)
	end
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
-----------------------------------------------------------------------------------------------------------------------------------------------
local function sendFolder(name,path,foreach)
	if(not fs.isDirectory(path)) then return print("Нельзя вводить имена файлов!") end
	if not fs.exists(path) then return print("Папка не найдена!") end
	if(foreach == 0) then
		modem.broadcast(port,"SRF_sendfolder_query",fs.name(path), name)
		print("Отправляю запрос на сервер " .. name)
	end
	local maxPacketSize = modem.maxPacketSize() - 64
	local data
	while true do
		local e = { event.pull(10,"modem_message") }
		if e[6] == "query_ok" then
			for file in fs.list(path) do
				if(string.find(file,"/")) then
					modem.broadcast(port,"folder",name,fs.name(file))
					print("Отправка подпапки " .. file .. " серверу " .. name .. "...")
					sendFolder(name,path .. "/" .. file,1)
				else
					local filelol = io.open(path .. "/" .. file,"rb")
					data = filelol:read(maxPacketSize)
					modem.broadcast(port,"filesendstart",name, file)
					while data do
						modem.broadcast(port,"filesend", data, name, file)
						data = filelol:read(maxPacketSize)
						os.sleep(0.1)
					end
					modem.broadcast(port, "filesendend", name, fs.name(file))
					filelol:close()
					print("Файл " .. fs.name(file) .. " успешно отправлен на сервер " .. name .. "!")
				end
			end
			if(foreach == 0) then
				modem.broadcast(port, "foldersendend", name, fs.name(path))
				return print("Папка " .. fs.name(path) .. " успешно отправлена на сервер " .. name .. "!")
			else
				modem.broadcast(port, "twofoldersendend", name, fs.name(path))
				return print("Подпапка " .. fs.name(path) .. " успешно отправлена на сервер " .. name .. "!" )
			end
		elseif not e[1] then
			return print("Отправка папки " .. fs.name(path) .. " от сервера " .. name .. " закончилась с ошибкой. Сервер не отвечает.")
		end
	end
end
local function receiveFolder(name,path,foreach)
	local fullPath = "/SSF_files/" .. name .. "/" .. path
	fs.makeDirectory("/SSF_files/" .. name .. "/" .. path)
	if(foreach == 0) then
		modem.broadcast(port,"SRF_receivefolder_query",path, name)
		print("Отправляю запрос на сервер " .. name)
	end
	while true do
		local e = { event.pull(10,"modem_message") }
		if(e[4] == port and e[6] == "error_folder_404" and e[7] == name) then
			return print("Приём папки " .. fs.name(path) .. " от сервера " .. name .. " неудачен. Файл не найден.")
		end
		if(e[4] == port and e[6] == "error_no_folder" and e[7] == name) then
			return print("Приём папки " .. fs.name(path) .. " от сервера " .. name .. " неудачен. Это не папка.")
		end
		if(e[4] == port and e[6] == "filesendstartServer" and e[7] == name) then
			file = io.open(fullPath .. e[8], "w")
		end
		if(e[4] == port and e[6] == "filesendServer" and e[8] == name) then
	  	file:write(e[7])
		end
		if(e[4] == port and e[6] == "filesendendServer" and e[7] == name) then
			file:close()
			print("Приём файла " .. e[8] .. " от сервера " .. e[7] .. " успешно завершен")
		end
		if(e[4] == port and e[6] == "folderServer" and e[7] == name) then
			print("Приём подпапки " .. e[8] .. " от сервера " .. name .. "...")
			receiveFolder(name,e[8],1)
		end
		if(e[4] == port and e[6] == "foldersendendServer" and e[7] == name) then
			print("Приём папки " .. e[8] .. " от сервера " .. name .. " успешно завершен")
			break
		end
		if(e[4] == port and e[6] == "twofoldersendendServer" and e[7] == name) then
			print("Приём подпапки " .. e[8] .. " от сервера " .. name .. " успешно завершен")
			break
		elseif not e[1] then
			return print("Ошибка приёма папки " .. fs.name(path) .. ". Сервер " .. name .. " не отвечает.")
		end
	end 
end
local args, options = shell.parse(...)
if(args[1] == nil or args[2] == nil) then return print("Введите адрес и путь к файлу (SSF [имя сервера] [файл/путь к нему] [куда? (при флаге -r)] [-r - получает файл от сервера, -f - отправить/получить папку])") end
for x, i in pairs(options) do
	if x ~= "r" and x ~= "f" then return print("Неверный аргумент!") end
end
if not options["r"] and not options["f"]  then
	sendFile(args[1],args[2])
elseif options["r"] and not options["f"] then
	receiveFile(args[1],args[2])
elseif not options["r"] and options["f"] then
	sendFolder(args[1],args[2],0)
elseif options["r"] and options["f"] then
	receiveFolder(args[1],args[2],0)
else return print("Неверный аргумент!") end