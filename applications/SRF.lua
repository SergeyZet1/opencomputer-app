------------Библиотеки--------------------
local component = require("component")
local event = require("event")
local fs = require("filesystem")
------------------------------------------
require("term").clear()
local port = 515
local modem = component.modem
local maxPacketSize = modem.maxPacketSize() - 32
modem.open(port)
modem.setStrength(3000)
print("Введите имя сервера: ")
local servername = require("term").read()
servername = string.sub(servername,0,string.len(servername) - 1)
modem.broadcast(port,"SRF_servername_query", servername)
while true do
  local e = { event.pull(1,"modem_message") }
  if e[4] == port and e[6] == "fuckyou" then
	print("Это имя уже занято, используйте другое")
	return false
  elseif not e[1] then break end
end
require("term").clear()
-----------Функции-------------
local function receiveFile(remoteAddress, fileName)
  fs.makeDirectory("/SRF_files/" .. string.sub(remoteAddress,0,4))
  local file = io.open("/SRF_files".. "/" .. string.sub(remoteAddress,0,4) .. "/" .. fileName, "w")
  modem.send(remoteAddress,port,"query_ok")
  while true do
    local e = { event.pull(10,"modem_message") }
	--[[for x,i in pairs(e) do
		print("Аргумент " .. x .. ": " .. i) 
	end]]
    if(e[3] == remoteAddress and e[4] == port and e[6] == "filesend" and e[8] == servername) then
	  file:write(e[7])
	  modem.send(remoteAddress,port,"query_ok")
    elseif(e[4] == port and e[6] == "filesendend" and e[7] == servername) then
	  if(e[3] == remoteAddress) then
		file:close()
		print("Отправка файла " .. fileName .. " от клиента " .. string.sub(remoteAddress,0,4) .. " успешно завершено")
	  end
      break
    elseif not e[1] then
      file:close()
      fs.remove("/SRF_files".. "/" .. string.sub(remoteAddress,0,4) .. "/" .. fileName)
      return print("Ошибка передачи файла " .. fileName .. ". Клиент не отвечает (адрес " .. string.sub(remoteAddress,0,4) .. ")")
    end
  end
end
------------------------------------------------------------------------------------------------------------------------------
local function sendFile(remoteAddress, fileName)
	local client = string.sub(remoteAddress,0,4)
	local file = io.open("/SRF_files".. "/" .. client .. "/" .. fileName, "rb")
	local maxPacketSize = modem.maxPacketSize() - 32
	local data
	if not file then
		modem.send(remoteAddress,port,"query_error",servername)
		return print("Передача файла " .. fileName .. " клиенту с адресом " .. client .. " закончилось с ошибкой. Файл не найден." )
	end
	modem.send(remoteAddress,port,"query_ok",servername)
	while true do
		data = file:read(maxPacketSize)
		local e = { event.pull(3, "modem_message") }
		if e[4] == port and e[6] == "SSF_ok" and e[7] == servername then
			if data then
				modem.send(remoteAddress, port,"filesend", data, servername)
			else
				break
			end
		elseif not e[1] then
			return print("Передача файла " .. fileName .. " клиенту с адресом " .. client .. " закончилось с ошибкой. Клиент не отвечает." )
		end
	end
	file:close()
	modem.send(remoteAddress,port, "filesendend", servername)
	print("Передача файла " .. fileName .. " клиенту с адресом " .. client .. " успешно завершена.")
end
------------------------------------------------------------------------------------------------------------------------------
local function receiveFolder(remoteAddress, folderName, path)
	path = path .. "/" .. folderName
	fs.makeDirectory(path)
	modem.send(remoteAddress,port,"query_ok")
	local file
	while true do
		local e = { event.pull(10,"modem_message") }
		if(e[3] == remoteAddress and e[4] == port and e[6] == "filesendstart" and e[7] == servername) then
				file = io.open("/" .. path .. "/" .. e[8], "w")
				print(path .. "/" .. e[8])
		end
		if(e[3] == remoteAddress and e[4] == port and e[6] == "filesend" and e[8] == servername) then
	  	file:write(e[7])
		end
		if(e[3] == remoteAddress and e[4] == port and e[6] == "filesendend" and e[7] == servername) then
			file:close()
			print("Отправка файла " .. e[8] .. " от клиента " .. string.sub(remoteAddress,0,4) .. " успешно завершена")
		end
		if(e[3] == remoteAddress and e[4] == port and e[6] == "folder" and e[7] == servername) then
			print("Приём подпапки " .. e[8] .. " от клиента " .. string.sub(remoteAddress,0,4) .. "...")
			receiveFolder(remoteAddress,e[8], path)
		end
		if(e[3] == remoteAddress and e[4] == port and e[6] == "foldersendend" and e[7] == servername) then
			print("Отправка папки " .. folderName .. " от клиента " .. string.sub(remoteAddress,0,4) .. " успешно завершена")
			break
		end
		if(e[3] == remoteAddress and e[4] == port and e[6] == "twofoldersendend" and e[7] == servername) then
			print("Отправка подпапки " .. folderName .. " от клиента " .. string.sub(remoteAddress,0,4) .. " успешно завершена")
			break
		elseif not e[1] then
			return print("Ошибка приёма папки " .. folderName .. ". Клиент не отвечает (адрес " .. string.sub(remoteAddress,0,4) .. ")")
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------
local function sendFolder(remoteAddress, folderName, path, foreach)
	local fullPath = path .. folderName
	if not fs.exists(fullPath) then 
		modem.send(remoteAddress,port,"error_folder_404",servername)
		return print("Передача папки " .. folderName .. " клиенту с адресом " .. string.sub(remoteAddress,0,4) .. " закончилось с ошибкой. Папка не найдена.") 
	end
	if not fs.isDirectory(fullPath) then 
		modem.send(remoteAddress,port,"error_no_folder",servername)
		return print("Передача папки" .. folderName .. " клиенту с адресом " .. string.sub(remoteAddress,0,4) .. " закончилось с ошибкой. Это не папка.") 
	end
	local maxPacketSize = modem.maxPacketSize() - 64
	local data
	while true do
		for file in fs.list(fullPath) do
			if(string.find(file,"/")) then
				modem.broadcast(port,"folderServer",servername,fs.name(file))
				print("Отправка подпапки " .. file .. " клиенту " .. string.sub(remoteAddress,0,4) .. "...")
				sendFolder(remoteAddress,file,fullPath .. "/",1)
			else
					print(fullPath .. "/" .. file)
					local filelol = io.open(fullPath .. "/" .. file,"rb")
					data = filelol:read(maxPacketSize)
					modem.broadcast(port,"filesendstartServer",servername, file)
					while data do
						modem.broadcast(port,"filesendServer", data, servername, file)
						data = filelol:read(maxPacketSize)
						os.sleep(0.1)
					end
					modem.broadcast(port, "filesendendServer", servername, fs.name(file))
					filelol:close()
					print("Отправка файла " .. fs.name(file) .. " клиенту " .. string.sub(remoteAddress,0,4) .. " успешно завершена")
			end
		end
		if(foreach == 0) then
			modem.broadcast(port, "foldersendendServer", servername, folderName)
			return print("Отправка папки " .. folderName .. " клиенту " .. string.sub(remoteAddress,0,4) .. " успешно завершена")
		else
			modem.broadcast(port, "twofoldersendendServer", servername, folderName)
			return print("Отправка подпапки " .. folderName .. " от клиента " .. string.sub(remoteAddress,0,4) .. " успешно завершена")
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------
local function SendFileList(address,Path,foreach)
	local fullPath
	if foreach == 0 then
 		fullPath = "/SRF_files/" .. string.sub(address,0,4) .. "/" .. Path .. "/"
 	else
 		fullPath = Path
 	end
	if not fs.exists(fullPath) then
		modem.broadcast(port,"query_FL_error",servername)
		return print("Клиент " .. string.sub(address,0,4) .. " не смог получить список файлов. Папки/файла не существует.")
	end
	while true do
		if(foreach == 0) then
			modem.broadcast(port,"query_FL_start",servername)
			print("Клиент " .. string.sub(address,0,4) .. " запросил список файлов по пути " .. fullPath)
		end
		for file in fs.list(fullPath) do
			if(fs.isDirectory(fullPath .. file)) then
				SendFileList(address,fullPath .. fs.name(file) .. "/",1)
			end
			modem.broadcast(port,"query_FL",servername,fullPath .. file)
		end
		if(foreach == 0) then
			modem.broadcast(port,"query_FL_end",servername)
			print("Передача списка файла клиенту " .. string.sub(address,0,4) .. " успешно!")
			break
		end
		break
	end	
end
---------------------------------------------------------------------------------------------------------------------------------------
while true do
  local e = { event.pull("modem_message") }
  if(e[4] == port) then
  	if(e[6] == "SRF_sendfile_query" and e[8] == servername) then
			print("Запрос на принятие файла " .. e[7] .. " от клиента с адресом " .. string.sub(e[3],0,4))
    	receiveFile(e[3],e[7])        
		elseif(e[6] == "SRF_receivefile_query" and e[8] == servername) then
			print("Запрос на отправку файла " .. e[7] .. " клиенту с адресом " .. string.sub(e[3],0,4))
			sendFile(e[3],e[7])
		elseif(e[6] == "SRF_sendfolder_query" and e[8] == servername) then
			print("Запрос на принятие папки " .. e[7] .. " от клиента с адресом " .. string.sub(e[3],0,4))
    	receiveFolder(e[3],e[7],"SRF_files/" .. string.sub(e[3],0,4))
    elseif(e[6] == "SRF_receivefolder_query" and e[8] == servername) then
    	print("Запрос на отправку папки " .. e[7] .. " клиенту с адресом " .. string.sub(e[3],0,4) .. "/")
    	sendFolder(e[3],e[7],"/SRF_files/" .. string.sub(e[3],0,4) .. "/",0)
		elseif(e[6] == "SRF_servername_query" and e[7] == servername) then
			modem.broadcast(port,"fuckyou")
		elseif(e[6] == "SRF_sendFL_query" and e[7] == servername) then
			SendFileList(e[3],e[8],0)
		end
  end
end