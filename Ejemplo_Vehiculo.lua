--[[
	EJEMPLO DE SCRIPT PARA LA IMPLANTACION DEL ASFA EN UN VEHÍCULO FERROVIARIO
	JALTA : 11-11-2020
]]


--Tipo de ASFA
ASFA_TIPO = "NuevoEquipo" --Si el panel repetidor es del nuevo equipo
--ASFA_TIPO = "Clasico" --Si el panel repetidor es el clásico
  
function Initialise()

	--Seleccion del tipo de vehículo
	CarId = Call("GetRVNumber")
	CompPL = 0 --Determina si la composicion es llevada por el jugador
	CompPLant = 0 --Determina si antes era del jugador
	VehiculoJugador = 0 --Determina si éste vehículo de la composición del jugador es el que lleva el jugador.
	VehiculoJugadorAnt = 0 --Determina si éste vehículo de la composición del jugador es el que lleva el jugador antes.
	
	
	
	--Definicion de otras variables del vehículo
	battery = false
	Inicializa = false
	ASFAcorte = false --Esta variable interviene el freno de emergencia por el ASFA
	--ASFAArranqueAut = true --Esta variable hace arrancar el ASFA directamente al cargar el escenario
	--
	--
	
	--Carga el script del ASFA
	ASFAexiste = false
	local ASFAdir = "Assets\\JALTA\\RailNetwork\\ASFA\\ASFAclasico.out"
	local error_lectura = ""
	local file, error_lectura = io.open(ASFAdir, "r")
	if error_lectura == nil then
		io.close(file)
		dofile(ASFAdir)
		ASFAexiste = true
		
		--Configuracion del ASFA
		ASFAconfig()
		
	else
		SysCall("ScenarioManager:ShowAlertMessageExt", "ASFA script:", "Error: No se puede cargar el archivo del ASFA", 10, 0)
	end
	
	Call("BeginUpdate")
	
end

--Esta función se ejecuta cuando una variable de control cambia
function OnControlValueChange(name, index, value)	

	--Pulsadores del ASFA:
	if ASFAexiste == true then
		ASFAPulsadores(name, index, value)
	end
	
	--Resto de código asociado a esta funcion
	if Call("*:ControlExists", name, index) then
		Call("*:SetControlValue", name, index, value)
	end
	
end

--Lectura de mensajes al paso por una baliza de señal
function OnCustomSignalMessage ( arg )
	
	--Lectura de los mensajes procedentes de las balizas por parte del Captador del ASFA
	if ASFAexiste == true then
		ASFAcaptador(arg)
	end

 end

--Bucle principal del programa
function Update(time)

	--Inicializa
	if Inicializa == false then
		Inicializa = true
		--Codigo asociado al inicio. Se ejecuta solo una vez al principo
		--
		--
	end
	
	--Determina si el tren pasa a ser del jugador o de la IA:
	CompPL = Call("GetIsPlayer")
	
	--Determina si el vehículo es llevado por el jugador (habilitado), o forma parte de la composición del jugador (no habilitado).
	VehiculoJugador = Call("GetIsEngineWithKey")
	
	--Transicion de tren que es de la IA a tren que es del Jugador. 
	if CompPL ~= CompPLant then
		--Ahora éste es del jugador
		if CompPL == 1 then 
			--SysCall ( "ScenarioManager:ShowAlertMessageExt" , "JALTA:", "Vehiculo "..tostring(CarId).." pasa a ser del jugador", 10 , 32 )
			--Código asociado a esta parte
			--
			--
		--Ahora es de la IA.
		else 	
			--SysCall ( "ScenarioManager:ShowAlertMessageExt" , "JALTA:", "Vehiculo "..tostring(CarId).." pasa a ser de la IA", 10 , 32 )
			--Código asociado a esta parte
			--
			--
		end 
	end
	CompPLant = CompPL
	
	--Transicion de vehículo no habilitado a habilitado.
	if VehiculoJugador ~= VehiculoJugadorAnt then
		--Ahora éste es el habilitado
		if VehiculoJugador == 1 then 
			--SysCall ( "ScenarioManager:ShowAlertMessageExt" , "JALTA:", "Vehiculo "..tostring(CarId).." abandona la habilitacion", 10 , 32 )
			--Código asociado a esta parte: Cambio de Cabina
			--
			--
		--Si no es el que abandona la habilitacion.
		else 
			--SysCall ( "ScenarioManager:ShowAlertMessageExt" , "JALTA:", "Vehiculo "..tostring(CarId).." abandona la habilitacion", 10 , 32 )
			--Código asociado a esta parte: Cambio de Cabina
			--
			--
		end 
	end
	VehiculoJugadorAnt=VehiculoJugador
	
	--VEHÍCULO DE LA COMPOSICION DEL JUGADOR
	------------------------------------------------------------------------------------------------
	if CompPL == 1 then
	
		--Comportamiento del vehículo que dirige el usuario dentro de la composición del usuario (ej: locomotora titular)
		if VehiculoJugador == 1 then
			
			
			--Aquí se actualiza el ASFA
			if ASFAexiste == true then
				
				ASFAcorte = ASFAControl(time,battery) --Si siempre esta conectada la bateria, dejar en true

			end
			
			--Freno de emergencia causado por intervencion del ASFA
			if ASFAcorte == true then
				Call( "*:SetControlValue", "TrainBrakeControl", 0, 1)
			end
			
			--Código asociado a esta parte: Otros controles de la cabina: Hombre muerto, luces, puertas, etc...
			--
			--
			
		
		--Comportamiento del vehiculo cuando esta dentro de la composición que dirige el usuario (ej locomotora de la doble traccion)
		elseif VehiculoJugador == 0 then 
		
			--Código asociado a esta parte
			--
			--
			
		end
		
	
	--VEHÍCULO DE UNA COMPOSICIÓN IA
	---------------------------------------------------------------------------------------------------
   	elseif CompPL==0 then 
		--Código asociado a esta parte
		--
		--
	end
	
	--ZONA COMÚN PARA CUALQUIER TIPO DE COMPOSICIÓN:
		--Código asociado a esta parte
		--
		--
end
  
--Mensajes entre vehículos de la composicion
function OnConsistMessage(msg, argument, direction)
	
end


function OnCameraEnter(p_nCabEnd, p_nCarriageCam)

end

function OnCameraLeave()
  
end