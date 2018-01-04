local computer = require("computer")

print( "Загрузка..." )
os.sleep(1)
local a = 440
for i = 1, 10 do
print("Проверка цикла", i)
computer.beep(a, 0.5)
a = a + 100
os.sleep(1)
end
computer.beep(2000, 0.1)
print("/-/-/-/-/-/-/-/")
print("Бункер v1.5   /")
print("/-/-/-/-/-/-/-/")
os.sleep(1)

print("В бункере есть: спальня, комната смотрителя, душ, ванна, выход наружу, ж/д, столовая, алхимия, дискотека")
os.sleep(2)

print("Создатели бункера: Ваня (battlenet.gwynbleidd), Серёга (SergeyZet (SergeyRus1212))")
os.sleep(2)

print("Жильцы дома: Рейз (ImReyzzz), DED (ENOT^^)")
os.sleep(2)
print("Тост за локалхост!")
print("                                              31.07.17")

