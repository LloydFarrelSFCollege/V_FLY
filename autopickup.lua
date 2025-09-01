local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickUpItemRequest = ReplicatedStorage:WaitForChild("network"):WaitForChild("RemoteFunction"):WaitForChild("pickUpItemRequest")

local ItemsFolder = workspace:WaitForChild("placeFolders"):WaitForChild("items")
local localUserId = Players.LocalPlayer.UserId  -- Obtenemos la UserId solo una vez al principio
local userIdStr = tostring(localUserId)  -- Convertimos a string para comparar con nombres de objetos

local function pickUpOwnedItems()
    for _, item in ipairs(ItemsFolder:GetChildren()) do
        local ownersFolder = item:FindFirstChild("owners")
        if ownersFolder and ownersFolder:FindFirstChild(userIdStr) then
            PickUpItemRequest:InvokeServer(item)
        end
    end
end

-- Auto recolector cada 0.1s
while true do
    pickUpOwnedItems()
    task.wait(0.1)
end
