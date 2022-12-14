---@module TextStyling/lib/Types
local Types = require(script:FindFirstChild("Types"));
export type TextStyling = Types.TextStyling;

--[=[
    @class TextStyling

    This class was designed to simplify the colours used in text and allows you to use colour & format codes which then are converted into font tags for rich text.

    ## Colour Codes
        &0 - Black
        &1 - Dark Blue
        &2 - Dark Green
        &3 - Dark Aqua
        &4 - Dark Red
        &5 - Dark Purple
        &6 - Orange
        &7 - Gray
        &8 - Dark Gray
        &9 - Blue
        &a - Green
        &b - Aqua
        &c - Red
        &d - Light Purple
        &e - Yellow
        &f - White
        &g - Gold
    ## Format Codes
        &l - Bold
        &m - Strikethrough
        &n - Underline
        &s - Stroke
        &o - Italic
        &r - Reset
]=]
local TextStyling = {} :: TextStyling;
TextStyling.__index = TextStyling;

TextStyling.ColourCodeMap = {
    ["0"] = "rgb(0,0,0)",
    ["1"] = "rgb(0,0,170)",
    ["2"] = "rgb(0,170,0)",
    ["3"] = "rgb(0,170,170)",
    ["4"] = "rgb(170,0,0)",
    ["5"] = "rgb(170,0,170)",
    ["6"] = "rgb(255,170,0)",
    ["7"] = "rgb(170,170,170)",
    ["8"] = "rgb(85,85,85)",
    ["9"] = "rgb(85,85,255)",
    ["a"] = "rgb(85,255,85)",
    ["b"] = "rgb(85,255,255)",
    ["c"] = "rgb(255,85,85)",
    ["d"] = "rgb(255,85,255)",
    ["e"] = "rgb(255,255,85)",
    ["f"] = "rgb(255,255,255)",
    ["g"] = "rgb(221,214,5)"
};

TextStyling.FormatCodeMap = {
    ["l"] = {"<b>","</b>"},
    ["m"] = {"<s>","</s>"},
    ["n"] = {"<u>","</u>"},
    ["s"] = {"<stroke>","</stroke>"},
    ["o"] = {"<i>","</i>"}
};

local function formatRichColour(colourRGB: string) : string
    return string.format("<font color=\"%s\">",colourRGB);
end

--[=[
    @param parsedText string -- The text that will be parsed
    @param activeFormats {string} -- This table stores the active format codes currently in use

    This function is for opening the font tags for format codes.
]=]
function TextStyling.OpenFormatCodes(parsedText: string,activeFormats: {string}) : string
    for i,formatCode: string in ipairs(activeFormats) do
        local formatT: {string} = TextStyling.FormatCodeMap[formatCode];
        if formatT then
            parsedText = parsedText..formatT[1];
        end
    end
    return parsedText;
end

--[=[
    @param parsedText string -- The text that will be parsed
    @param activeFormats {string} -- This table stores the active format codes currently in use
    @param clearFormat boolean? -- When this is true it will remove all of the currently active format codes

    This function is for closing the font tags for format codes.
]=]
function TextStyling.CloseFormatCodes(parsedText: string,activeFormats: {string},clearFormat: boolean?) : string
    for i = #activeFormats,1,-1 do
        local formatT: {string} = TextStyling.FormatCodeMap[activeFormats[i]];
        if formatT then
            parsedText = parsedText..formatT[2];
        end
        if clearFormat then table.remove(activeFormats,i) end;
    end
    return parsedText;
end

--[=[
    This function takes in a text and when any colour codes are found they will be converted into font rich text format.
]=]
function TextStyling.ParseTextCodes(text: string) : string
    local parsedText: string = "";

    local ignoreNext: boolean = false;

    local prevColourCode: string? = nil;
    local activeFormats: {string} = {};

    local currentIndex: number = 0;
    while currentIndex < #text do
        currentIndex += 1;
        local char: string = text:sub(currentIndex,currentIndex);
        if ignoreNext then
            ignoreNext = false;
            continue;
        end
        if char == "&" then
            -- Only check for escape key when the index is not 1
            if currentIndex > 1 then
                local prevIndex: number = currentIndex - 1;
                local prevChar: string = text:sub(prevIndex,prevIndex);
                -- Check for an escaped ampersand
                if prevChar == "\\" then parsedText = parsedText..char; continue; end
            end
            local nextIndex: number = currentIndex + 1;
            local codeChar: string = text:sub(nextIndex,nextIndex);
            if TextStyling.ColourCodeMap[codeChar] then
                -- Check for a rich text greater than
                if text:sub(nextIndex,nextIndex + 2) == "gt;" then
                    -- Jump past this &gt;
                    currentIndex = nextIndex + 2;
                    parsedText = parsedText.."&gt;";
                    continue;
                end
                if prevColourCode then
                    if prevColourCode == codeChar then ignoreNext = true; continue; end
                    -- Color code is used close format codes but don't remove
                    parsedText = TextStyling.CloseFormatCodes(parsedText,activeFormats);
                    -- The colour code is different so close off the last colour font tag
                    parsedText = parsedText.."</font>";
                    prevColourCode = nil;
                else
                    -- Color code is used close format codes but don't remove
                    parsedText = TextStyling.CloseFormatCodes(parsedText,activeFormats);
                end
                parsedText = parsedText..formatRichColour(TextStyling.ColourCodeMap[codeChar]);
                -- Reopen any format codes
                parsedText = TextStyling.OpenFormatCodes(parsedText,activeFormats);
                prevColourCode = codeChar;
            elseif TextStyling.FormatCodeMap[codeChar] then
                -- Check for a rich text less than
                if text:sub(nextIndex,nextIndex + 2) == "lt;" then
                    -- Jump past this &lt;
                    currentIndex = nextIndex + 2;
                    parsedText = parsedText.."&lt;";
                    continue;
                end
                -- Only do formatting with this code if it's not already active
                if table.find(activeFormats,codeChar) then
                    -- Ignore next char
                    ignoreNext = true;
                    continue;
                end
                parsedText = TextStyling.CloseFormatCodes(parsedText,activeFormats);
                table.insert(activeFormats,codeChar);
                parsedText = TextStyling.OpenFormatCodes(parsedText,activeFormats);
            elseif codeChar == "r" then
                -- Close and flush out the activeFormats
                parsedText = TextStyling.CloseFormatCodes(parsedText,activeFormats,true);
            else
                -- Don't ignore the next iteration if the char isn't recognized as a valid "text code"
                ignoreNext = true;
                continue;
            end
            -- Ignore the next char as it's part of the "text code"
            ignoreNext = true;
        else
            -- Add non "text code" chars to the parsedText
            parsedText = parsedText..char;
        end
    end
    parsedText = TextStyling.CloseFormatCodes(parsedText,activeFormats,true);
    if prevColourCode then
        parsedText = parsedText.."</font>";
        prevColourCode = nil;
    end
    return parsedText;
end

local disallowedRichText = {
	"<font%s*%w+%s*=%s*[^>]+>",
	"</font%s*>",
	"<stroke%s*>",
	"</stroke%s*>",
	"<b%s*>",
	"</b%s*>",
	"<i%s*>",
	"</i%s*>",
	"<u%s*>",
	"</u%s*>",
	"<s%s*>",
	"</s%s*>",
	"<br />",
	"<uppercase%s*>",
	"</uppercase%s*>",
	"<uc%s*>",
	"</uc%s*>",
	"<smallcaps%s*>",
	"</smallcaps%s*>",
	"<sc%s*>",
	"</sc%s*>",
	"<!--%s*%w*%s*-->"
};

--[=[
    This function strips all rich text away from text leaving just the plain text.
]=]
function TextStyling.StripRichText(text: string)
    for _,disallowPattern: string in ipairs(disallowedRichText) do
        text = text:gsub(disallowPattern,"");
    end
    return text;
end

return TextStyling;