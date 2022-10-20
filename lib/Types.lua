export type TextStyling = {
    __index: any,
    ColourCodeMap: Dictionary<string>,
    FormatCodeMap: Dictionary<{string}>,

    OpenFormatCodes: (parsedText: string,activeFormats: {string}) -> string,
    CloseFormatCodes: (parsedText: string,activeFormats: {string},clearFormat: boolean?) -> string,
    ParseTextCodes: (text: string) -> string,
    StripRichText: (text: string) -> ()
};

return true;