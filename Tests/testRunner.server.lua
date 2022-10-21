local TextStylingModule: ModuleScript = game.ServerScriptService:FindFirstChild("TextStyling");
if TextStylingModule then
    ---@module lib/Types
    local Types = require(TextStylingModule:FindFirstChild("Types"));
    local TextStyling: Types.TextStyling = require(TextStylingModule);
    local str: string = "&f&l[&rcccmdm&f&l]&r:";
    print(str);
    print(TextStyling.ParseTextCodes(str));
end