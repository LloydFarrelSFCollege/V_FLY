-- Script para eliminar RemoteEvents y RemoteFunctions específicos
-- Coloca este script en ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lista de objetos a eliminar (rutas relativas desde ReplicatedStorage)
local objectsToDelete = {
    "network.RemoteEvent.playerRequest_damageEntity",
    "network.RemoteFunction.playerRequest_applyDeathTrapToSelf", 
    "network.RemoteEvent.playerRequest_applyTrapDamageToSelf"
}

-- Función para navegar por la ruta y eliminar el objeto
local function deleteObjectByPath(startObject, path)
    local pathParts = string.split(path, ".")
    local currentObject = startObject
    
    -- Navegar hasta el objeto padre
    for i = 1, #pathParts - 1 do
        local part = pathParts[i]
        local found = currentObject:FindFirstChild(part)
        if found then
            currentObject = found
        else
            warn("No se encontró: " .. part .. " en la ruta " .. path)
            return false
        end
    end
    
    -- Intentar eliminar el objeto final
    local finalObjectName = pathParts[#pathParts]
    local objectToDelete = currentObject:FindFirstChild(finalObjectName)
    
    if objectToDelete then
        objectToDelete:Destroy()
        print("✅ Eliminado exitosamente: " .. path)
        return true
    else
        warn("❌ No se encontró el objeto: " .. finalObjectName .. " en " .. path)
        return false
    end
end

-- Función principal
local function deleteTargetObjects()
    print("🔄 Iniciando eliminación de objetos...")
    
    local deletedCount = 0
    local totalCount = #objectsToDelete
    
    for _, objectPath in ipairs(objectsToDelete) do
        if deleteObjectByPath(ReplicatedStorage, objectPath) then
            deletedCount = deletedCount + 1
        end
        wait(0.1) -- Pequeña pausa entre eliminaciones
    end
    
    print("📊 Proceso completado: " .. deletedCount .. "/" .. totalCount .. " objetos eliminados")
end

-- Ejecutar la función
deleteTargetObjects()
