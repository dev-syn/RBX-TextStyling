local TextStylingModule: ModuleScript = game.ServerScriptService:FindFirstChild("TextStyling");
if TextStylingModule then
    ---@module lib/Types
    local Types = require(TextStylingModule:FindFirstChild("Types"));
    local TextStyling: Types.TextStyling = require(TextStylingModule);
    
end