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
      print("Ошибка передачи файла " .. fileName .. ". Клиент не отвечает (адрес " .. string.sub(remoteAddress,0,4) .. ")")
	  break
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
while true do
  local e = { event.pull("modem_message") }
  if(e[4] == port) then
  	if(e[6] == "SRF_sendfile_query" and e[8] == servername) then
			print("Запрос на принятие файла " .. e[7] .. " от клиента с адресом " .. string.sub(e[3],0,4))
    	receiveFile(e[3],e[7])        
		elseif(e[6] == "SRF_receivefile_query" and e[8] == servername) then
			print("Запрос на отправку файла " .. e[7] .. " клиенту с адресом " .. string.sub(e[3],0,4))
			sendFile(e[3],e[7])
		elseif(e[6] == "SRF_servername_query" and e[7] == servername) then
			modem.broadcast(port,"fuckyou")
		end
  end
end