local remote_spy = {}
local remotes = {}
local ignore = {}

local _
local env = oh.environment
local gui = oh.gui
local assets = oh.assets
local terminal = oh.terminal

local body = gui.Base.Body
local window = body.RemoteSpy
local logged = window.Logged
local options = window.Options

local inspection = body.RemoteSpyInspection

local tween_service = game:GetService("TweenService")
local selected = "RemoteEvent"

local gmt = env.getmetatable(game)
local nmc = gmt.__namecall

--[[
    A U X I L I A R Y
]]--

local is_remote = function(object)
    return object:IsA("RemoteEvent") or object:IsA("RemoteFunction") or object:IsA("BindableEvent") or object:IsA("BindableFunction")
end

local find_remote = function(name)1
    for i,v in next, remotes do
        if i.Name:sub(1, name:len()):lower() == name:lower() then
            return i
        end
    end
end

--[[
    C O R E 
]]--

local new_log = function(t, i, results)
    local log = oh.assets.RemoteResult:Clone()

    for i,v in next, results do
        
    end
end

for i,v in next, game:GetDescendants() do
    local results = setmetatable({}, { __newindex = new_log })
    _ = is_remote(v) and rawset(remotes, v, results)
end

game.DescendantAdded:Connect(function(object)
    _ = is_remote(object) and rawset(remotes, object, {})
end)

game.DescendantRemoving:Connect(function(object)
    _ = rawget(remotes, object) and rawset(remotes, object, nil)
end)

setreadonly(gmt, false)
gmt.__namecall = function(obj, ...)
    local method = env.get_namecall()
    local vargs = {...}
    local methods = {
        FireServer = true,
        InvokeServer = true,
        Fire = true,
        Invoke = true
    }

    if methods[method] and not ignore[obj] then
        table.insert(remotes[obj], vargs)
    end

    return nmc(obj, ...)
end

--[[
    T E R M I N A L   C O M M A N D S
]]--

remote_spy.prefix = "rs"

remote_spy.spy = function(remote_name)
    local remote = find_remote(remote_name)
    terminal.output(remote_spy.prefix, Color3.fromRGB(255, 170, 0), "spying on " .. remote.Name)
end

remote_spy.ignore = function(remote_name)
    local remote = find_remote(remote_name)
    terminal.output(remote_spy.prefix, Color3.fromRGB(255, 170, 0), "ignoring " .. remote.Name)
end

remote_spy.inspect = function(remote_name)
    local remote = find_remote(remote_name)
    ignore[remote] = true
    terminal.output(remote_spy.prefix, Color3.fromRGB(255, 170, 0), "inspecting " .. remote.Name)
end

--[[
    I N T E R F A C E   F U N C T I O N S
]]--

for i,v in next, options:GetChildren() do
    v.MouseButton1Click:Connect(function()
        local anim = tween_service:Create(v, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
        anim:Play()
        
        selected = v.Name
    end)

    v.MouseEnter:Connect(function()
        if selected ~= v.Name then
            local anim = tween_service:Create(v, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            anim:Play()
        end
    end)

    v.MouseLeave:Connect(function()
        if selected ~= v.Name then
            local anim = tween_service:Create(v, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
            anim:Play()
        end
    end)
end

return remote_spy