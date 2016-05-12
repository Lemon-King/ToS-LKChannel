if not _G["LKAddon"] then
    _G["LKAddon"] = {};
end
local LKAddon = _G["LKAddon"];

if not _G["math"].lerp then
    _G["math"].lerp = function(a, b, t)
        return (1 - t) * a + t * b;
    end
end

local Version = "v0.01";

local g_ColorRange = {
    [0] = {255, 255, 255},    -- Light
    [1] = {255, 204, 51},     -- Normal
    [2] = {255, 127, 0},      -- Heavy
    [3] = {255, 0, 0},        -- Full
    [4] = {159, 0, 255},      -- Locked
};
local g_PopColorRange = #g_ColorRange - 1;
local g_PopSegment = 1 / g_PopColorRange;

function LKAddon.GetChannelString(zoneInst)
	local popMax = session.serverState.GetMaxPCCount();
    local population = zoneInst.pcCount;
    if population == -1 then
        population = popMax;
    end
    
    -- simple rgb color blender
    local pctPop = population / popMax;
    local index = math.floor(pctPop * g_PopColorRange);
    local pctColor = (pctPop - (index * g_PopSegment)) / g_PopSegment;
    local low = g_ColorRange[index];
    local high = g_ColorRange[index+1];
    local color = {255,255,255};
    for i = 1, 3 do
        color[i] = math.lerp(low[i], high[i],  pctColor);
    end
    
    local fontStr = string.format("{@st42b}{#%02X%02X%02X}", color[1], color[2], color[3]);
	local stateString = fontStr .. string.format("%s / %s ", population, popMax) .. "{img channel_mark_full 14 20 C}";
	local ret = fontStr .. string.format("%s %d", ClMsg("Channel"), zoneInst.channel + 1);
	
	return ret, stateString;
end

local isLoaded = false;
function LKCHANNEL_ON_INIT(addon, frame)
	if isLoaded then
		return nil;
	end
	isLoaded = true;
    
    _G["GET_CHANNEL_STRING"] = LKAddon.GetChannelString;
	ui.SysMsg(string.format("Accurate Channels %s", Version));
end