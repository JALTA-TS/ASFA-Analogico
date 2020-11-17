--[[
 SCRIPT ASFA CLASICO
 (C) JALTA 2020
-----------------------------------------------------------------------------------------------
]]


--JAT: Función Configura ASFA.
--Genera las variables de control del ASFA
function ASFAconfig()

	--Constantes
	gRev = "Alpha 0.75 - 05112020" --Version del script
	ASFA_NO_ALIM = 0
	ASFA_APAGADO = 1
	ASFA_ARRANQUE = 2
	ASFA_EFICACIA = 3
	ASFA_PERDIDA_EFICACIA = 4
	ASFA_ANULADO = 5
	ASFA_REARME_EFICACIA = 6
	ASFA_ARRANQUE_ERROR = 7
	
	
	--Variables
	ASFAestado = ASFA_NO_ALIM
	ASFAinicio = false
	ASFAfreq = "Null"
	ASFAinterviene = false
	ASFAcont	= 0
	ASFARebCont = 0
	ASFARebase	= false
	ASFAcontArranque = 0
	ASFAcontFallo = 0
	ASFAConex = false
	ASFABTRebase = false 
	ASFABTRearme = false
	ASFABTAlarma = false
	ASFABTSeta = true
	ASFARearme = false
	ASFAAveria = 0
	ASFAArranqueAut = false
	ASFAbeepL3 = 0.5
	ASFATipo = ""
	ASFAemergencia = false
	ASFAemergenciaAnt = false
	
end

--JAT: Función captador del ASFA
--Descodifica los mensajes llegados por la baliza
function ASFAcaptador(mensaje)

	--Captador del ASFA:
	--Lectura erronea por averia 
	if ASFAAveria == 1 then
		ASFAfreq = "ALARMA"
		ASFAAveria = 0
		
	--Via libre (L3)
	elseif mensaje == "68310" then
		ASFAfreq = "L3"
		--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Lectura Baliza ASFA: "..ASFAfreq, 5, 0)
	
	--Frenar (L1)
	elseif mensaje == "60000" then
		ASFAfreq = "L1"
		--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Lectura Baliza ASFA: "..ASFAfreq, 5, 0)
	
	--Parada Baliza Previa (L7)
	elseif mensaje == "88540" then
		ASFAfreq = "L7"
		--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Lectura Baliza ASFA: "..ASFAfreq, 5, 0)
	
	--Parada Baliza Señal (L8)
	elseif mensaje == "95500" then
		ASFAfreq = "L8"
		--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Lectura Baliza ASFA: "..ASFAfreq, 5, 0)
	
	--No hagas nada para éstos argumentos.
	elseif mensaje == "blocked" or mensaje == "warning" or mensaje =="warning2" or mensaje =="warning3" or mensaje =="clear" then
	
	--Alarma. No se reconoce la frecuencia.
	else
		ASFAfreq = "ALARMA"
		--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Lectura Baliza ASFA: "..ASFAfreq, 5, 0)
	end
	
	--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Lectura Baliza ASFA: "..ASFAfreq, 5, 0)
	
end

--JAT: Funcion pulsadores del ASFA.
--Script de respuesta cuando de usa algún pulsador del ASFA
function ASFAPulsadores(name, index, value)
	
	--Llave conexión
	if name == "ASFA_LLAVE" then
		Call("*:SetControlValue", name, index, value)
		if value == 0.5 then
			ASFAConex = true
			ASFABTRebase = false
		elseif value == 0 then
			ASFAConex = false
			ASFABTRebase = false
		elseif value == 1 then
			ASFAConex = true
			ASFABTRebase = true
		end
	
	--Interruptor de Conexión (nuevos paneles )
	elseif name == "ASFA_BT_CONEX" then
		Call("*:SetControlValue", name, index, value)
		if value == 1 then
			ASFAConex = true
		elseif value == 0 then
			ASFAConex = false
		end
		
	--Reconocimiento botones ASFA
	elseif name == "ASFA_BT_REC" then
		Call("*:SetControlValue", name, index, value)
		if ASFAinterviene == false then
			Call("SetControlValue", "ASFA_LUZ_FRENAR", 0,0)
			Call("SetControlValue", "ASFA_LUZ_REC", 0,0)
			Call("SetControlValue", "ASFA_BEEP", 0,0)
			ASFAfreq = "Null"
			ASFAcont = 0
		end
	
	elseif name == "ASFA_BT_REC_PANEL" then
		Call("*:SetControlValue", name, index, value)
		if ASFAinterviene == false then
			Call("SetControlValue", "ASFA_LUZ_FRENAR", 0,0)
			Call("SetControlValue", "ASFA_LUZ_REC", 0,0)
			Call("SetControlValue", "ASFA_BEEP", 0,0)
			ASFAfreq = "Null"
			ASFAcont = 0
		end
	
	--Pulsador de Alarma
	elseif name == "ASFA_BT_ALARMA" then
		Call("*:SetControlValue", name, index, value)
		
		if value > 0.5 then
			ASFABTAlarma = true
		elseif value <0.3 then
			ASFABTAlarma = false
		end
		
		--[[if ASFARearme == false then
			Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,0)
			Call("SetControlValue", "ASFA_BEEP", 0,0)
			ASFAfreq = "Null"
			ASFAcont = 0
		end]]
		
	--Interruptor Rebase Autorizado
	elseif name == "ASFA_BT_REBASE" then
		Call("*:SetControlValue", name, index, value)
		if value > 0.5 then
			ASFABTRebase = true
		elseif value <0.3 then
			ASFABTRebase = false 
		end
		
	--Pulsador de Rearme
	elseif name == "ASFA_BT_REARME" then
		Call("*:SetControlValue", name, index, value)
		if value > 0.5 then
			ASFABTRearme = true
		elseif value < 0.3 then
			ASFABTRearme = false
		end
	end
end

--JAT: Función ASFA Control
--Control del ASFA. Se llama des de la función update.
function ASFAControl(time, alimentacion)
	
	velocidad = math.abs(Call("GetSpeed"))*3.6 --Velocidad real en km/h
	
	--Ejecución por primera vez del algoritmo
	if ASFAinicio == false then
		ASFATipo = ASFA_TIPO
		ASFAinicio = true
		ASFAinterviene = true
		
		--Call("SetControlValue", "ASFA_INTERVENCION", 0,1)
		
		local texto = " "
		
		if ASFATipo == "NuevoEquipo" then
			ASFAbeepL3 = 0.5
			texto = "ASFA Nuevo Equipo. Version: "..gRev
			
		elseif ASFATipo == "Clasico" then
			ASFAbeepL3 = 0.25
			texto = "ASFA Clasico. Version: "..gRev
		else
			ASFAbeepL3 = 0.5
			texto = "No es posible determinar. Se aplican parametros por defecto. Version: "..gRev
		end
		
		SysCall("ScenarioManager:ShowAlertMessageExt", "JALTA","Script ASFA activado: "..texto, 5, 0)
		
	end
	
	--Maquina de estados. Acciones.
	if ASFAestado == ASFA_NO_ALIM then --No hay bateria
		--SysCall("ScenarioManager:ShowAlertMessageExt", "JALTA", "He entrado aqui "..tostring(ASFAestado), 5, 0)
		
	elseif ASFAestado == ASFA_APAGADO then --Hay bateria, pero esta apagado el equipo
		--SysCall("ScenarioManager:ShowAlertMessageExt", "JALTA", "He entrado aqui "..tostring(ASFAestado), 5, 0)
		
	elseif ASFAestado == ASFA_ARRANQUE then --Arranque. Comprovación y transición a eficacia si todo OK
		--SysCall("ScenarioManager:ShowAlertMessageExt", "JALTA", "He entrado aqui "..tostring(ASFAestado), 5, 0)
		ASFAcontArranque = ASFAcontArranque + time
			
	elseif ASFAestado == ASFA_EFICACIA then --Eficacia. El ASFA esta funcionando.
	
		--Via libre
		if ASFAfreq == "L3" then
			Call("SetControlValue", "ASFA_BEEP", 0,1) --Control relacionado con el Beep de sonido.
			ASFAcont = ASFAcont + time
			--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Lectura Baliza ASFA: "..tostring(ASFAcont), 5, 0)
			if ASFAcont >= ASFAbeepL3 then
				ASFAcont = 0
				Call("SetControlValue", "ASFA_BEEP", 0,0)
				ASFAfreq = "Null"
			end
			
		--Frenar
		elseif ASFAfreq == "L1" then
			ASFAcont = ASFAcont + time
			Call("SetControlValue", "ASFA_LUZ_FRENAR", 0,1)
			Call("SetControlValue", "ASFA_LUZ_REC", 0,1)
			Call("SetControlValue", "ASFA_BEEP", 0,1)
			if ASFAcont >= 3 then
				--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Frenada de Emergencia causada por el ASFA. Una vez detenido pulse Shift+U para rearmar o Boton REARME FRENO", 30, 0)
				--Call("SetControlValue", "ASFA_INTERVENCION", 0,1)
				ASFAinterviene = true
				ASFARearme = true
				ASFAcont = 0
				ASFAfreq = "Null"
			end
		
		--Parada Baliza Previa
		elseif ASFAfreq == "L7" then
			ASFAcont = ASFAcont + time
			Call("SetControlValue", "ASFA_LUZ_ROJA", 0,1)
			if velocidad >= 60 then --Control de velocidad por baliza previa.
				Call("SetControlValue", "ASFA_BEEP", 0,1)
				--Call("SetControlValue", "ASFA_INTERVENCION", 0,1)
				--SysCall("ScenarioManager:ShowAlertMessageExt", "RENFE 446", "Frenada de Emergencia causada por el ASFA. Una vez detenido pulse Shift+U para rearmar o Boton REARME FRENO", 30, 0)
				ASFAinterviene = true
				ASFARearme = true
				ASFAcont = 0
				ASFAfreq = "Null"
			elseif ASFAcont >= 10 then
				Call("SetControlValue", "ASFA_LUZ_ROJA", 0,0)
				ASFAcont = 0
				ASFAfreq = "Null"
			elseif ASFAcont >= 3 then
				Call("SetControlValue", "ASFA_BEEP", 0,0)
			
			elseif ASFAcont >=0.1 then
				Call("SetControlValue", "ASFA_BEEP", 0,1)
				
			end
			
		--Parada
		elseif ASFAfreq == "L8" then
			Call("SetControlValue", "ASFA_LUZ_ROJA", 0,1)
			Call("SetControlValue", "ASFA_BEEP", 0,1)
			--Si no esta activado el rebase autorizado:
			if ASFARebase == false then
				--Call("SetControlValue", "ASFA_INTERVENCION", 0,1)
				--SysCall("ScenarioManager:ShowAlertMessageExt", "ASFA", "Frenada de Emergencia causada por el ASFA. Una vez detenido pulse el Boton REARME FRENO", 30, 0)
				ASFAinterviene = true
				ASFARearme = true
				ASFAfreq = "Null"
			else --Si lo está:
				ASFAfreq = "L8+Reb"
			end
			
		--Parada con temporizador de Rebase Autorizado
		elseif ASFAfreq == "L8+Reb" then
			ASFAcont = ASFAcont + time
			if ASFAcont >= 10 then
				Call("SetControlValue", "ASFA_LUZ_ROJA", 0,0)
				ASFAcont = 0
				ASFAfreq = "Null"
			elseif ASFAcont >= 3 then
				Call("SetControlValue", "ASFA_BEEP", 0,0)
			end
			
		--Alarma
		elseif ASFAfreq == "ALARMA" then
			ASFAcont = ASFAcont + time
			Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,1)
			Call("SetControlValue", "ASFA_BEEP", 0,1)
			if ASFAcont >= 3 then
				--Call("SetControlValue", "ASFA_INTERVENCION", 0,1)
				ASFAinterviene = true
				ASFARearme = true
				ASFAcont = 0
			elseif ASFABTAlarma == true then
				Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,0)
				Call("SetControlValue", "ASFA_BEEP", 0,0)
				ASFAfreq = "Null"
				ASFAcont = 0
			end
		end
		
		--Pulsador // llave de Rebase Autorizado.
		if ASFABTRebase == true and ASFARebCont < 10 then
			if Call("*:ControlExists", "ASFA_LUZ_REBAUTO" , 0) then
				Call("SetControlValue", "ASFA_LUZ_REBAUTO", 0,1)
			end	
			ASFARebCont = ASFARebCont + time
			ASFARebase	= true
			if ASFARebCont >= 10 then
				ASFARebase	= false
				if Call("*:ControlExists", "ASFA_LUZ_REBAUTO" , 0) then
					Call("SetControlValue", "ASFA_LUZ_REBAUTO", 0,0)
				end	
				--SysCall("ScenarioManager:ShowAlertMessageExt", "ASFA", "Fin del contador de Rebase", 5, 0)
			end
		elseif ASFABTRebase == false then
			if Call("*:ControlExists", "ASFA_LUZ_REBAUTO" , 0) then
				Call("SetControlValue", "ASFA_LUZ_REBAUTO", 0,0)
			end	
			ASFARebCont = 0
		end
	
	elseif ASFAestado == ASFA_PERDIDA_EFICACIA then --Se ha perdido la eficacia. 3s para recuperarla con el pulsador de alarma.
			ASFAcont = ASFAcont + time

			if ASFAcont >= 3 then
				--Call("SetControlValue", "ASFA_INTERVENCION", 0,1)
				ASFAinterviene = true
				ASFARearme = true
				ASFAcont = 0
			end
		
	
	elseif ASFAestado == ASFA_ANULADO then --Se ha anulado el equipo. 
	
	end
	
	
	--Transiciones entre estados-------------------------------------------------
	--Transicion de NO_ALIM a APAGADO
	if ASFAestado == ASFA_NO_ALIM and alimentacion == true and ASFAConex == false then
		ASFAestado = ASFA_APAGADO
		if Call("*:ControlExists", "ASFA_LUZ_CONEX" , 0) then
			Call("SetControlValue", "ASFA_LUZ_CONEX", 0,1)
		end
	
	--Transicion de NO_ALIM a ERROR_ARRANQUE (Si al dar alimentación esta el botón de conexión dado o la llave, genera una alarma)
	elseif (ASFAestado == ASFA_NO_ALIM and alimentacion == true and ASFAConex == true) then
		ASFAestado = ASFA_ARRANQUE_ERROR
		Call("SetControlValue", "ASFA_LUZ_EFICACIA", 0,0)
		Call("SetControlValue", "ASFA_LUZ_ROJA", 0,1)
		Call("SetControlValue", "ASFA_BEEP", 0,1)
		Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,1)
		--Call("SetControlValue", "ASFA_INTERVENCION", 0,1)
		ASFAinterviene = true
		ASFARearme = true
		
	--Transicion de ERROR ARRANQUE A EFICACIA
	elseif (ASFAestado == ASFA_ARRANQUE_ERROR and ASFABTAlarma == true) then
		ASFAestado = ASFA_EFICACIA
		Call("SetControlValue", "ASFA_LUZ_EFICACIA", 0,1)
		Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,0)

	--Transicion de NO_ALIM a ANULADO
	elseif ASFAestado == ASFA_NO_ALIM and alimentacion == true and ASFABTSeta == false then
		ASFAestado = ASFA_ANULADO
		
		
	--Transicion de APAGADO a ARRANQUE
	elseif ASFAestado == ASFA_APAGADO and (ASFAConex == true or ASFAArranqueAut == true) then
		if ASFAArranqueAut == true then 
			ASFAConex = true
			ASFAArranqueAut = false
		end
		ASFAestado = ASFA_ARRANQUE
		ASFAcontArranque = 0
		Call("SetControlValue", "ASFA_BEEP", 0,1)
		Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,1)
		if Call("*:ControlExists", "ASFA_LUZ_REARME" , 0) then
			Call("SetControlValue", "ASFA_LUZ_REARME", 0,1)
		end
		if Call("*:ControlExists", "ASFA_LUZ_CONEX" , 0) then
			Call("SetControlValue", "ASFA_LUZ_CONEX", 0,0)
		end
		--SysCall("ScenarioManager:ShowAlertMessageExt", "JALTA", "He entrado aqui "..tostring(ASFAestado), 5, 0)
	
	--Transicion de ARRANQUE a EFICACIA
	elseif ASFAestado == ASFA_ARRANQUE and ASFAcontArranque > 0.5 then
		ASFAcontArranque = 0
		ASFAestado = ASFA_EFICACIA
		Call("SetControlValue", "ASFA_BEEP", 0,0)
		Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,0)
		Call("SetControlValue", "ASFA_LUZ_EFICACIA", 0,1)
		if Call("*:ControlExists", "ASFA_LUZ_REARME" , 0) then
			Call("SetControlValue", "ASFA_LUZ_REARME", 0,0)
		end
		ASFAinterviene = false
	
	--Transicion de EFICACIA a PERDIDA DE EFICACIA
	elseif ASFAestado == ASFA_EFICACIA and ASFAAveria == 3 then
	
		local EliminaAveria = math.random(1,5)
		if EliminaAveria == 3 then --25%de probabilidad de eliminar la averia, si no persiste durante 1 min (hasta que se vuelve a generar un numero nuevo)
			ASFAAveria = 0
		end
		ASFAestado = ASFA_PERDIDA_EFICACIA
		Call("SetControlValue", "ASFA_LUZ_EFICACIA", 0,0)
		Call("SetControlValue", "ASFA_BEEP", 0,1)
		Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,1)
		ASFAcont = 0
		ASFAfreq = "Null"
		
	--Transicion de PERDIDA de EFICACIA a REARME EFICACIA
	elseif ASFAestado == ASFA_PERDIDA_EFICACIA and ASFABTAlarma == true then
		ASFAestado = ASFA_REARME_EFICACIA
		Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,0)
	
	--Transicion de REARME EFICACIA a EFICACIA
	elseif ASFAestado == ASFA_REARME_EFICACIA then
		ASFAestado = ASFA_EFICACIA
		ASFAcont = 0
		ASFAfreq = "Null"
		Call("SetControlValue", "ASFA_LUZ_EFICACIA", 0,1)
	
	--Transicion de Cualquier estado a APAGADO
	elseif (ASFAestado == ASFA_ARRANQUE or ASFAestado == ASFA_EFICACIA or ASFAestado == ASFA_PERDIDA_EFICACIA or ASFAestado == ASFA_REARME_EFICACIA or ASFAestado == ASFA_ANULADO) and ASFAConex == false then
		ASFAestado = ASFA_APAGADO
		ASFARebCont = 0
		ASFAcont = 0
		ASFAfreq = "Null"
		--ASFAeficacia = false
		ASFAinterviene = true
		ASFARearme = false
		Call("SetControlValue", "ASFA_BEEP", 0,0)
		Call("SetControlValue", "ASFA_LUZ_EFICACIA", 0,0)
		Call("SetControlValue", "ASFA_LUZ_ROJA", 0,0)
		Call("SetControlValue", "ASFA_LUZ_VERDE", 0,0)
		Call("SetControlValue", "ASFA_LUZ_FRENAR", 0,0)
		Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,0)
		Call("SetControlValue", "ASFA_LUZ_REC", 0,0)
		if Call("*:ControlExists", "ASFA_LUZ_CONEX" , 0) then
			Call("SetControlValue", "ASFA_LUZ_CONEX", 0,1)
		end
		if Call("*:ControlExists", "ASFA_LUZ_REARME" , 0) then
			Call("SetControlValue", "ASFA_LUZ_REARME", 0,0)
		end
		if Call("*:ControlExists", "ASFA_LUZ_REBAUTO" , 0) then
			Call("SetControlValue", "ASFA_LUZ_REBAUTO", 0,0)
		end	
	
	--Transicion de Cualquier estado a NO ALIMENTACION
	elseif alimentacion == false and ASFAestado ~= ASFA_NO_ALIM then
		ASFAestado = ASFA_NO_ALIM
		ASFARebCont = 0
		ASFAcont = 0
		ASFAfreq = "Null"
		--ASFAeficacia = false
		ASFAinterviene = true
		ASFARearme = false
		Call("SetControlValue", "ASFA_BEEP", 0,0)
		Call("SetControlValue", "ASFA_LUZ_EFICACIA", 0,0)
		Call("SetControlValue", "ASFA_LUZ_ROJA", 0,0)
		Call("SetControlValue", "ASFA_LUZ_VERDE", 0,0)
		Call("SetControlValue", "ASFA_LUZ_FRENAR", 0,0)
		Call("SetControlValue", "ASFA_LUZ_ALARMA", 0,0)
		Call("SetControlValue", "ASFA_LUZ_REC", 0,0)
		if Call("*:ControlExists", "ASFA_LUZ_CONEX" , 0) then
			Call("SetControlValue", "ASFA_LUZ_CONEX", 0,0)
		end
		if Call("*:ControlExists", "ASFA_LUZ_REARME" , 0) then
			Call("SetControlValue", "ASFA_LUZ_REARME", 0,0)
		end
		if Call("*:ControlExists", "ASFA_LUZ_REBAUTO" , 0) then
			Call("SetControlValue", "ASFA_LUZ_REBAUTO", 0,0)
		end
		
	end	
	
	--RERARME.
	if ASFARearme == true and velocidad < 5 then
		if Call("*:ControlExists", "ASFA_LUZ_REARME" , 0) then
			Call("SetControlValue", "ASFA_LUZ_REARME", 0,1)
		end
		if 	ASFABTRearme == true then
				Call("SetControlValue", "ASFA_BEEP", 0,0)
				Call("SetControlValue", "ASFA_LUZ_REC", 0,0)
				Call("SetControlValue", "ASFA_LUZ_FRENAR", 0,0)
				--Call("SetControlValue", "ASFA_INTERVENCION", 0,0)
				Call("SetControlValue", "ASFA_LUZ_ROJA", 0,0)
				if Call("*:ControlExists", "ASFA_LUZ_REARME" , 0) then
					Call("SetControlValue", "ASFA_LUZ_REARME", 0,0)
				end
				ASFAinterviene = false
				ASFARearme = false
		end
	end
	
	--Base de tiempo de 1 min para generar averias
	if ASFAestado ~= ASFA_NO_ALIM then
		ASFAcontFallo = ASFAcontFallo + time
		if ASFAcontFallo >= 60 then
			ASFAcontFallo = 0
			ASFAAveria = math.random(1,100)
			--SysCall("ScenarioManager:ShowAlertMessageExt", "JALTA", "Averia generada: "..tostring(ASFAAveria), 5, 0)
		end
	end
	
	--Intervencion del ASFA
	if ASFAinterviene == true or (ASFAestado ~= ASFA_EFICACIA and ASFAestado ~= ASFA_ANULADO)  then
		ASFAemergencia = true
	else
		ASFAemergencia = false
	end
	
	if ASFAemergencia ~= ASFAemergenciaAnt then
		if ASFAemergencia == true then
			Call("SetControlValue", "ASFA_INTERVENCION", 0,1)
		else
			Call("SetControlValue", "ASFA_INTERVENCION", 0,0)
		end
		ASFAemergenciaAnt = ASFAemergencia
	end
	
	return ASFAemergencia 
end