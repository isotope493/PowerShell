# (C) Copyright 2020. Brian R. Preston. All Rights Reserved

# Assumes, once the first parameter is identified through start-end delimiters, the value of the parameter immediately follows it and is terminated by the next parameter.
function Get-ParameterNameAndValuesFromString_ReturnArray
{
    [CmdletBinding()]
    param
    (
        #region Parameters

        # Input String
        [Parameter(Mandatory=$true)][Alias("Input")][string]$InputString,

        # Values to return
        [Parameter()][Alias("RetParamName")][bool]$ReturnParameterNamesToArray=$true,
        [Parameter()][Alias("RetParamValues")][bool]$ReturnParameterValuesToArray=$true,

        # Sorting prefence of array output
        [Parameter()][Alias("SortParamNames")][bool]$SortParameterNames=$false,
        [Parameter()][Alias("SortParamValues")][bool]$SortParameterValues=$false,
        [Parameter()][Alias("SortParamNameTop")][bool]$SortParameterNameThenParameterValues=$True,

        # Guess delimiters, parameter names, parameter values
        [Parameter()][Alias("BestGuess")][bool]$BestGuessDelimitersAndTextQualifiers=$null,

        # Are keywords and value free of spaces
        [Parameter()][Alias("ParamNameNoSpaces")][bool]$ParameterNamesIn_InputString_HaveNoSpaces=$null,
        [Parameter()][Alias("ParamValueNoSpaces")][bool]$ParameterValuesIn_InputString_HaveNoSpaces=$null,

        # Spaces are delimiters unless escaped or text qualified
        [Parameter()][Alias("SpacesAreDelimExcptIfEsc")][string]$TreatSpacesAsDelimitersUnlessEscapedOrTextQualified=$true,

        # Remove strings from input string; processed first 
        [Parameter()][Alias("RemStrFromInput")][string]$RemoveStringsFrom_InputString=$null,
        [Parameter()][Alias("RemStrFromInput")][char]$DelimiterCharacterFor_RemoveStringsFrom_InputString=$null,
        [Parameter()][Alias("RemStrSkipFirst")][bool]$IfRemovingStrings_SkipFirstCharacter=$null,
        [Parameter()][Alias("RemStrSkipLast")][bool]$IfRemovingStrings_SkipLastCharacter=$null,          
        
        # Delimiters for start and end of parameter names
        [Parameter()][Alias("ParamStartDelim")][String]$DelimitersFor_ParameterNameStart_InInputString=$null,
        [Parameter()][Alias("ParamEndDelim")][String]$DelimitersFor_ParameterNameEnd_InInputString=$null,

        # Delimiter and text qualifer to separate multiple user delimiters of parameter names; Must start-end delimiters match
        [Parameter()][Alias("ParamMultiDelims_Delim")][String]$DelimiterSeparating_MultipleStartEndParameterNameDelimiters_InThisCommand=$null,
        [Parameter()][Alias("ParamMultiDelims_TxtQual")][String]$TextQualifierFor_MultipleStartEndParameterNameDelimiters_InThisCommand=$null,
        [Parameter()][Alias("ParamDelimsStartEndMatch")][string]$DelimitersFor_ParameterNameStartAndEnd_MustMatch=$null,

        # Text qualifiers (intrepet contents as literal) for start and end of a string
        [Parameter()][Alias("TxtQualStart")][string]$TextQualifiersFor_StartOfLiteralString_InInputString=$null,
        [Parameter()][Alias("TxtQualEnd")][string]$TextQualifiersFor_EndOfLiteralString_InInputString=$null,

        # Delimiter and text qualifer to separate multiple user inputed text qualifiers; Must start-end delimiters match
        [Parameter()][Alias("TxtQualMulti_Delim")][string]$DelimiterSeparating_MultipleStartEndTextQualifiers_InThisCommand=$null,
        [Parameter()][Alias("TxtQualMulti_TxtQual")][string]$TextQualifierFor_MultipleStartEndTextQualifiers_InThisCommand=$null,
        [Parameter()][Alias("TxtQualStartEndMatch")][string]$TextQualifiersFor_StartAndEndOfLiteralString_MustMatch=$null,

        # Escape special characters (e.g. delimiter, text qualifier) in input string when processing 
        [Parameter()][Alias("EscStrLiteralChar")][string]$StringIndicating_FollowingCharacterInInputString_IsLiteral=$null,

        # Conditions when to ignore escape string
        [Parameter()][Alias("IgnoreEscStrWithinParamName")][bool]$IgnoreNextCharacterIsLiteralIf_WithinParameterName=$null,
        [Parameter()][Alias("IgnoreEscStrWithinParamVal")][bool]$IgnoreNextCharacterIsLiteralIf_WithinParameterValue=$null,
        [Parameter()][Alias("IgnoreEscStrWithinTxtQualStr")][bool]$IgnoreNextCharacterIsLiteralIf_WithinTextQualifiedString=$null,
        [Parameter()][Alias("IgnoreEscStrIfNxtCharNotSpec")][bool]$IgnoreEscapeStringIfNextCharacterIsNotSpecial=$null,



        #region Delimiters for Start of Parameter Name

        [Parameter()][Alias("ParamDelimS_Space")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Space=$null,
        [Parameter()][Alias("ParamDelimS_BkQuote")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_BackQuote=$null,
        [Parameter()][Alias("ParamDelimS_Tilde")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Tilde=$null,
        [Parameter()][Alias("ParamDelimS_Exclamation")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Exclamation=$null,
        [Parameter()][Alias("ParamDelimS_At")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_AtOrAmpersat=$null,
        [Parameter()][Alias("ParamDelimS_Hash")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_PoundOrHash=$null, 
        [Parameter()][Alias("ParamDelimS_USD")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_USD=$null,
        [Parameter()][Alias("ParamDelimS_Pct")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Percent=$null,
        [Parameter()][Alias("ParamDelimS_Caret")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Caret=$null,  
        [Parameter()][Alias("ParamDelimS_Ampersand")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Ampersand=$null,
        [Parameter()][Alias("ParamDelimS_Asterisk")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Asterisk=$null,
        [Parameter()][Alias("ParamDelimS_OpenParen")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_OpenParen=$null,
        [Parameter()][Alias("ParamDelimS_CloseParen")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_CloseParen=$null,
        [Parameter()][Alias("ParamDelimS_Hypen")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Hyphen=$null,
        [Parameter()][Alias("ParamDelimS_Underscore")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Underscore=$null,
        [Parameter()][Alias("ParamDelimS_Equal")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Equal=$null,
        [Parameter()][Alias("ParamDelimS_Plus")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Plus=$null,
        [Parameter()][Alias("ParamDelimS_OpenBracket")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_OpenBracket=$null,
        [Parameter()][Alias("ParamDelimS_CloseBracket")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_CloseBracket=$null,
        [Parameter()][Alias("ParamDelimS_OpenBrace")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_OpenBrace=$null,
        [Parameter()][Alias("ParamDelimS_CloseBrace")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_CloseBrace=$null,
        [Parameter()][Alias("ParamDelimS_Comma")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Comma=$null,
        [Parameter()][Alias("ParamDelimS_Period")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Period=$null,
        [Parameter()][Alias("ParamDelimS_Pipe")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_VerticalBarOrPipe=$null,        
        [Parameter()][Alias("ParamDelimS_BkSlash")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_BackSlash=$null,
        [Parameter()][Alias("ParamDelimS_FwdSlash")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_ForwardSlash=$null,
        [Parameter()][Alias("ParamDelimS_SnglQuote")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_SingleQuote=$null,
        [Parameter()][Alias("ParamDelimS_DblQuote")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_DoubleQuote=$null,
        [Parameter()][Alias("ParamDelimS_Color")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Colon=$null,
        [Parameter()][Alias("ParamDelimS_SemiColon")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_SemiColon=$null,
        [Parameter()][Alias("ParamDelimS_LessThan")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_LessThanAngleBracket=$null,
        [Parameter()][Alias("ParamDelimS_GreaterThan")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_GreaterThanAngleBracket=$null,
        [Parameter()][Alias("ParamDelimS_Question")][bool]$DelimiterFor_ParameterNameStart_IsSymbol_Question=$null,

        #endregion Delimiters for Start of Parameter Name

        #region Delimiters for End of Parameter Name

        [Parameter()][Alias("ParamDelimE_Space")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Space=$null,
        [Parameter()][Alias("ParamDelimE_BkQuote")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_BackQuote=$null,
        [Parameter()][Alias("ParamDelimE_Tilde")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Tilde=$null,
        [Parameter()][Alias("ParamDelimE_Exclamation")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Exclamation=$null,
        [Parameter()][Alias("ParamDelimE_At")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_AtOrAmpersat=$null,
        [Parameter()][Alias("ParamDelimE_Hash")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_PoundOrHash=$null, 
        [Parameter()][Alias("ParamDelimE_USD")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_USD=$null,
        [Parameter()][Alias("ParamDelimE_Pct")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Percent=$null,
        [Parameter()][Alias("ParamDelimE_Caret")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Caret=$null,  
        [Parameter()][Alias("ParamDelimE_Ampersand")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Ampersand=$null,
        [Parameter()][Alias("ParamDelimE_Asterisk")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Asterisk=$null,
        [Parameter()][Alias("ParamDelimE_OpenParen")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_OpenParen=$null,
        [Parameter()][Alias("ParamDelimE_CloseParen")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_CloseParen=$null,
        [Parameter()][Alias("ParamDelimE_Hypen")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Hyphen=$null,
        [Parameter()][Alias("ParamDelimE_Underscore")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Underscore=$null,
        [Parameter()][Alias("ParamDelimE_Equal")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Equal=$null,
        [Parameter()][Alias("ParamDelimE_Plus")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Plus=$null,
        [Parameter()][Alias("ParamDelimE_OpenBracket")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_OpenBracket=$null,
        [Parameter()][Alias("ParamDelimE_CloseBracket")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_CloseBracket=$null,
        [Parameter()][Alias("ParamDelimE_OpenBrace")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_OpenBrace=$null,
        [Parameter()][Alias("ParamDelimE_CloseBrace")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_CloseBrace=$null,
        [Parameter()][Alias("ParamDelimE_Comma")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Comma=$null,
        [Parameter()][Alias("ParamDelimE_Period")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Period=$null,
        [Parameter()][Alias("ParamDelimE_Pipe")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_VerticalBarOrPipe=$null,        
        [Parameter()][Alias("ParamDelimE_BkSlash")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_BackSlash=$null,
        [Parameter()][Alias("ParamDelimE_FwdSlash")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_ForwardSlash=$null,
        [Parameter()][Alias("ParamDelimE_SnglQuote")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_SingleQuote=$null,
        [Parameter()][Alias("ParamDelimE_DblQuote")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_DoubleQuote=$null,
        [Parameter()][Alias("ParamDelimE_Color")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Colon=$null,
        [Parameter()][Alias("ParamDelimE_SemiColon")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_SemiColon=$null,
        [Parameter()][Alias("ParamDelimE_LessThan")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_LessThanAngleBracket=$null,
        [Parameter()][Alias("ParamDelimE_GreaterThan")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_GreaterThanAngleBracket=$null,
        [Parameter()][Alias("ParamDelimE_Question")][bool]$DelimiterFor_ParameterNameEnd_IsSymbol_Question=$null,

        #endregion Delimiters for End of Parameter Name

        #region Delimiters for Start of Text Qualifier

        [Parameter()][Alias("TxtQualiferS_BkQuote")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_BackQuote=$null,
        [Parameter()][Alias("TxtQualiferS_Tilde")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Tilde=$null,
        [Parameter()][Alias("TxtQualiferS_Exclamation")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Exclamation=$null,
        [Parameter()][Alias("TxtQualiferS_At")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_AtOrAmpersat=$null,
        [Parameter()][Alias("TxtQualiferS_Hash")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_PoundOrHash=$null, 
        [Parameter()][Alias("TxtQualiferS_USD")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_USD=$null,
        [Parameter()][Alias("TxtQualiferS_Pct")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Percent=$null,
        [Parameter()][Alias("TxtQualiferS_Caret")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Caret=$null,  
        [Parameter()][Alias("TxtQualiferS_Ampersand")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Ampersand=$null,
        [Parameter()][Alias("TxtQualiferS_Asterisk")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Asterisk=$null,
        [Parameter()][Alias("TxtQualiferS_OpenParen")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_OpenParen=$null,
        [Parameter()][Alias("TxtQualiferS_CloseParen")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_CloseParen=$null,
        [Parameter()][Alias("TxtQualiferS_Hypen")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Hyphen=$null,
        [Parameter()][Alias("TxtQualiferS_Underscore")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Underscore=$null,
        [Parameter()][Alias("TxtQualiferS_Equal")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Equal=$null,
        [Parameter()][Alias("TxtQualiferS_Plus")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Plus=$null,
        [Parameter()][Alias("TxtQualiferS_OpenBracket")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_OpenBracket=$null,
        [Parameter()][Alias("TxtQualiferS_CloseBracket")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_CloseBracket=$null,
        [Parameter()][Alias("TxtQualiferS_OpenBrace")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_OpenBrace=$null,
        [Parameter()][Alias("TxtQualiferS_CloseBrace")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_CloseBrace=$null,
        [Parameter()][Alias("TxtQualiferS_Comma")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Comma=$null,
        [Parameter()][Alias("TxtQualiferS_Period")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Period=$null,
        [Parameter()][Alias("TxtQualiferS_Pipe")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_VerticalBarOrPipe=$null,        
        [Parameter()][Alias("TxtQualiferS_BkSlash")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_BackSlash=$null,
        [Parameter()][Alias("TxtQualiferS_FwdSlash")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_ForwardSlash=$null,
        [Parameter()][Alias("TxtQualiferS_SnglQuote")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_SingleQuote=$null,
        [Parameter()][Alias("TxtQualiferS_DblQuote")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_DoubleQuote=$null,
        [Parameter()][Alias("TxtQualiferS_Color")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Colon=$null,
        [Parameter()][Alias("TxtQualiferS_SemiColon")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_SemiColon=$null,
        [Parameter()][Alias("TxtQualiferS_LessThan")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_LessThanAngleBracket=$null,
        [Parameter()][Alias("TxtQualiferS_GreaterThan")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_GreaterThanAngleBracket=$null,
        [Parameter()][Alias("TxtQualiferS_Question")][bool]$DelimiterFor_TextQualifierStringStart_IsSymbol_Question=$null,

        #endregion Delimiters for Start of Text Qualifier

        #region Delimiters for End of Text Qualifier

        [Parameter()][Alias("TxtQualiferE_BkQuote")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_BackQuote=$null,
        [Parameter()][Alias("TxtQualiferE_Tilde")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Tilde=$null,
        [Parameter()][Alias("TxtQualiferE_Exclamation")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Exclamation=$null,
        [Parameter()][Alias("TxtQualiferE_At")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_AtOrAmpersat=$null,
        [Parameter()][Alias("TxtQualiferE_Hash")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_PoundOrHash=$null, 
        [Parameter()][Alias("TxtQualiferE_USD")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_USD=$null,
        [Parameter()][Alias("TxtQualiferE_Pct")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Percent=$null,
        [Parameter()][Alias("TxtQualiferE_Caret")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Caret=$null,  
        [Parameter()][Alias("TxtQualiferE_Ampersand")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Ampersand=$null,
        [Parameter()][Alias("TxtQualiferE_Asterisk")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Asterisk=$null,
        [Parameter()][Alias("TxtQualiferE_OpenParen")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_OpenParen=$null,
        [Parameter()][Alias("TxtQualiferE_CloseParen")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_CloseParen=$null,
        [Parameter()][Alias("TxtQualiferE_Hypen")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Hyphen=$null,
        [Parameter()][Alias("TxtQualiferE_Underscore")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Underscore=$null,
        [Parameter()][Alias("TxtQualiferE_Equal")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Equal=$null,
        [Parameter()][Alias("TxtQualiferE_Plus")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Plus=$null,
        [Parameter()][Alias("TxtQualiferE_OpenBracket")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_OpenBracket=$null,
        [Parameter()][Alias("TxtQualiferE_CloseBracket")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_CloseBracket=$null,
        [Parameter()][Alias("TxtQualiferE_OpenBrace")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_OpenBrace=$null,
        [Parameter()][Alias("TxtQualiferE_CloseBrace")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_CloseBrace=$null,
        [Parameter()][Alias("TxtQualiferE_Comma")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Comma=$null,
        [Parameter()][Alias("TxtQualiferE_Period")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Period=$null,
        [Parameter()][Alias("TxtQualiferE_Pipe")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_VerticalBarOrPipe=$null,        
        [Parameter()][Alias("TxtQualiferE_BkSlash")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_BackSlash=$null,
        [Parameter()][Alias("TxtQualiferE_FwdSlash")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_ForwardSlash=$null,
        [Parameter()][Alias("TxtQualiferE_SnglQuote")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_SingleQuote=$null,
        [Parameter()][Alias("TxtQualiferE_DblQuote")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_DoubleQuote=$null,
        [Parameter()][Alias("TxtQualiferE_Color")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Colon=$null,
        [Parameter()][Alias("TxtQualiferE_SemiColon")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_SemiColon=$null,
        [Parameter()][Alias("TxtQualiferE_LessThan")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_LessThanAngleBracket=$null,
        [Parameter()][Alias("TxtQualiferE_GreaterThan")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_GreaterThanAngleBracket=$null,
        [Parameter()][Alias("TxtQualiferE_Question")][bool]$DelimiterFor_TextQualifierStringEnd_IsSymbol_Question=$null,

        #endregion Delimiters for End of Text Qualifier

        #region Remove character from input string
        [Parameter()][Alias("RemoveChar_Space")][bool]$RemoveCharFromString_IsSymbol_Space=$null,
        [Parameter()][Alias("RemoveChar_BkQuote")][bool]$RemoveCharFromString_IsSymbol_BackQuote=$null,
        [Parameter()][Alias("RemoveChar_Tilde")][bool]$RemoveCharFromString_IsSymbol_Tilde=$null,
        [Parameter()][Alias("RemoveChar_Exclamation")][bool]$RemoveCharFromString_IsSymbol_Exclamation=$null,
        [Parameter()][Alias("RemoveChar_At")][bool]$RemoveCharFromString_IsSymbol_AtOrAmpersat=$null,
        [Parameter()][Alias("RemoveChar_Hash")][bool]$RemoveCharFromString_IsSymbol_PoundOrHash=$null, 
        [Parameter()][Alias("RemoveChar_USD")][bool]$RemoveCharFromString_IsSymbol_USD=$null,
        [Parameter()][Alias("RemoveChar_Pct")][bool]$RemoveCharFromString_IsSymbol_Percent=$null,
        [Parameter()][Alias("RemoveChar_Caret")][bool]$RemoveCharFromString_IsSymbol_Caret=$null,  
        [Parameter()][Alias("RemoveChar_Ampersand")][bool]$RemoveCharFromString_IsSymbol_Ampersand=$null,
        [Parameter()][Alias("RemoveChar_Asterisk")][bool]$RemoveCharFromString_IsSymbol_Asterisk=$null,
        [Parameter()][Alias("RemoveChar_OpenParen")][bool]$RemoveCharFromString_IsSymbol_OpenParen=$null,
        [Parameter()][Alias("RemoveChar_CloseParen")][bool]$RemoveCharFromString_IsSymbol_CloseParen=$null,
        [Parameter()][Alias("RemoveChar_Hypen")][bool]$RemoveCharFromString_IsSymbol_Hyphen=$null,
        [Parameter()][Alias("RemoveChar_Underscore")][bool]$RemoveCharFromString_IsSymbol_Underscore=$null,
        [Parameter()][Alias("RemoveChar_Equal")][bool]$RemoveCharFromString_IsSymbol_Equal=$null,
        [Parameter()][Alias("RemoveChar_Plus")][bool]$RemoveCharFromString_IsSymbol_Plus=$null,
        [Parameter()][Alias("RemoveChar_OpenBracket")][bool]$RemoveCharFromString_IsSymbol_OpenBracket=$null,
        [Parameter()][Alias("RemoveChar_CloseBracket")][bool]$RemoveCharFromString_IsSymbol_CloseBracket=$null,
        [Parameter()][Alias("RemoveChar_OpenBrace")][bool]$RemoveCharFromString_IsSymbol_OpenBrace=$null,
        [Parameter()][Alias("RemoveChar_CloseBrace")][bool]$RemoveCharFromString_IsSymbol_CloseBrace=$null,
        [Parameter()][Alias("RemoveChar_Comma")][bool]$RemoveCharFromString_IsSymbol_Comma=$null,
        [Parameter()][Alias("RemoveChar_Period")][bool]$RemoveCharFromString_IsSymbol_Period=$null,
        [Parameter()][Alias("RemoveChar_Pipe")][bool]$RemoveCharFromString_IsSymbol_VerticalBarOrPipe=$null,        
        [Parameter()][Alias("RemoveChar_BkSlash")][bool]$RemoveCharFromString_IsSymbol_BackSlash=$null,
        [Parameter()][Alias("RemoveChar_FwdSlash")][bool]$RemoveCharFromString_IsSymbol_ForwardSlash=$null,
        [Parameter()][Alias("RemoveChar_SnglQuote")][bool]$RemoveCharFromString_IsSymbol_SingleQuote=$null,
        [Parameter()][Alias("RemoveChar_DblQuote")][bool]$RemoveCharFromString_IsSymbol_DoubleQuote=$null,
        [Parameter()][Alias("RemoveChar_Color")][bool]$RemoveCharFromString_IsSymbol_Colon=$null,
        [Parameter()][Alias("RemoveChar_SemiColon")][bool]$RemoveCharFromString_IsSymbol_SemiColon=$null,
        [Parameter()][Alias("RemoveChar_LessThan")][bool]$RemoveCharFromString_IsSymbol_LessThanAngleBracket=$null,
        [Parameter()][Alias("RemoveChar_GreaterThan")][bool]$RemoveCharFromString_IsSymbol_GreaterThanAngleBracket=$null,
        [Parameter()][Alias("RemoveChar_Question")][bool]$RemoveCharFromString_IsSymbol_Question=$null
        #endregion Remove character from input string

        #endregion Parameters
    )

    #region Variables

    # [string]$input
    #region Input String: 
    # [Parameter(Mandatory=$true)][Alias("Input")][string]$InputString,
    $input="$InputString" 
    #endregion Input String

    # [string[]]$retNames [string[]]$retVals
    #region Return Values: 
    # Values to return
    # [Parameter()][Alias("RetParamName")][bool]$ReturnParameterNamesToArray=$true,
    # [Parameter()][Alias("RetParamValues")][bool]$ReturnParameterValuesToArray=$true,
    $retNames=$ReturnParameterNamesToArray
    $retVals=$ReturnParameterValuesToArray
    #endregion Return Values

    # [bool]$sortParamNames [bool]$sortParamVals [bool]$SortParamNamesTop
    #region Return Sort Preferences
    # Sorting prefence of array output
    # [Parameter()][Alias("SortParamNames")][bool]$SortParameterNames=$false,
    # [Parameter()][Alias("SortParamValues")][bool]$SortParameterValues=$false,
    # [Parameter()][Alias("SortParamNameTop")][bool]$SortParameterNameThenParameterValues=$True,
    $sortParamNames=$SortParameterNames
    $sortParamVals=$SortParameterValues
    $SortParamNamesTop=$SortParameterNameThenParameterValues
    #endregion Return Sort Preferences

    # [bool]$guess
    #region Guess Delimiters/Content: 
    # Guess delimiters, parameter names, parameter values
    # [Parameter()][Alias("BestGuess")][bool]$BestGuessDelimitersAndTextQualifiers=$null,
    $guess=$BestGuessDelimitersAndTextQualifiers
    #endregion Guess Delimiters/Content

    # [bool]$namesNoSpaces [bool]$valuesNoSpaces
    #region Are There Non-delimiting Spaces: 
    # Are keywords and value free of spaces
    # [Parameter()][Alias("ParamNameNoSpaces")][bool]$ParameterNamesIn_InputString_HaveNoSpaces=$null,
    # [Parameter()][Alias("ParamValueNoSpaces")][bool]$ParameterValuesIn_InputString_HaveNoSpaces=$null,
    $namesNoSpaces=$ParameterNamesIn_InputString_HaveNoSpaces
    $valuesNoSpaces=$ParameterValuesIn_InputString_HaveNoSpaces
    #endregion Are There Non-delimiting Spaces

    # [bool]$spacesAreDelimExcptEsc
    #region Spaces Are Delimiters Except When Escaped: 
    # Spaces are delimiters unless escaped or text qualified
    # [Parameter()][Alias("SpacesAreDelimExcptIfEsc")][string]$TreatSpacesAsDelimitersUnlessEscapedOrTextQualified=$true,
    $spacesAreDelimExcptEsc=$TreatSpacesAsDelimitersUnlessEscapedOrTextQualified
    #endregion Spaces Are Delimiters Except When Escaped

    # [string]$removeStrs [char]$removeStrs_InputDelimChar [bool]$removeStrs_SkipFirstChar [bool]$removeStrs_SkipLastChar
    #region Remove content from input string: 
    # Remove strings from input string; processed first 
    # [Parameter()][Alias("RemStrFromInput")][string]$RemoveStringsFrom_InputString=$null,
    # [Parameter()][Alias("RemStrFromInput")][char]$DelimiterCharacterFor_RemoveStringsFrom_InputString=$null,
    # [Parameter()][Alias("RemStrSkipFirst")][bool]$IfRemovingStrings_SkipFirstCharacter=$null,
    # [Parameter()][Alias("RemStrSkipLast")][bool]$IfRemovingStrings_SkipLastCharacter=$null,  
    $removeStrs=$RemoveStringsFrom_InputString
    $removeStrs_InputDelimChar=$DelimiterCharacterFor_RemoveStringsFrom_InputString
    $removeStrs_SkipFirstChar=$IfRemovingStrings_SkipFirstCharacter
    $removeStrs_SkipLastChar=$IfRemovingStrings_SkipLastCharacter
    #endregion Remove content from input string

    # [string]$paramDelimsStart [string]$paramDelimsEnd
    #region Delimiters for Param Names Start-End 
    # Delimiters for start and end of parameter names
    # [Parameter()][Alias("ParamStartDelim")][String]$DelimitersFor_ParameterNameStart_InInputString=$null,
    # [Parameter()][Alias("ParamEndDelim")][String]$DelimitersFor_ParameterNameEnd_InInputString=$null,
    $paramDelimsStart="$DelimitersFor_ParameterNameStart_InInputString"
    $paramDelimsEnd="$DelimitersFor_ParameterNameEnd_InInputString"
    #endregion Delimiters for Param Names Start-End

    # [string]$paramDelimOfDelims [string]$paramDelimsTxtQual [string]$paramDelimsStartEndMustMatch
    #region Delim/Txt Qualifier for user inputed delims for Param Names: 
    # Delimiter and text qualifer to separate multiple user delimiters of parameter names; Must start-end delimiters match
    # [Parameter()][Alias("ParamMultiDelims_Delim")][String]$DelimiterSeparating_MultipleStartEndParameterNameDelimiters_InThisCommand=$null,
    # [Parameter()][Alias("ParamMultiDelims_TxtQual")][String]$TextQualifierFor_MultipleStartEndParameterNameDelimiters_InThisCommand=$null,
    # [Parameter()][Alias("ParamDelimsStartEndMatch")][string]$DelimitersFor_ParameterNameStartAndEnd_MustMatch=$null,
    $paramDelimOfDelims="$DelimiterSeparating_MultipleStartEndParameterNameDelimiters_InThisCommand"
    $paramDelimsTxtQual="$TextQualifierFor_MultipleStartEndParameterNameDelimiters_InThisCommand"
    $paramDelimsStartEndMustMatch=$DelimitersFor_ParameterNameStartAndEnd_MustMatch
    #endregion Delim/Txt Qualifier for user inputed delims for Param Names

    # [string]$txtQualsStart [string]$txtQualsEnd
    #region Text Qualifiers for Literal String
    # Text qualifiers (intrepet contents as literal) for start and end of a string
    # [Parameter()][Alias("TxtQualStart")][string]$TextQualifiersFor_StartOfLiteralString_InInputString=$null,
    # [Parameter()][Alias("TxtQualEnd")][string]$TextQualifiersFor_EndOfLiteralString_InInputString=$null,
    $txtQualsStart="$TextQualifiersFor_StartOfLiteralString_InInputString"
    $txtQualsEnd="$TextQualifiersFor_EndOfLiteralString_InInputString"
    #endregion Text Qualifiers for Literal String

    # [string]$txtQualsDelim [string]$txtQualsDelimTxtQual [string]$txtQualsStartEndMustMatch
    #region Delim/Txt Qualifier for User Inputed Text Qualifiers
    # Delimiter and text qualifer to separate multiple user inputed text qualifiers; Must start-end delimiters match
    # [Parameter()][Alias("TxtQualMulti_Delim")][string]$DelimiterSeparating_MultipleStartEndTextQualifiers_InThisCommand=$null,
    # [Parameter()][Alias("TxtQualMulti_TxtQual")][string]$TextQualifierFor_MultipleStartEndTextQualifiers_InThisCommand=$null,
    # [Parameter()][Alias("TxtQualStartEndMatch")][string]$TextQualifiersFor_StartAndEndOfLiteralString_MustMatch=$null,
    $txtQualsDelim="$DelimiterSeparating_MultipleStartEndTextQualifiers_InThisCommand"
    $txtQualsDelimTxtQual="$TextQualifierFor_MultipleStartEndTextQualifiers_InThisCommand"
    $txtQualsStartEndMustMatch=$TextQualifiersFor_StartAndEndOfLiteralString_MustMatch
    #endregion Delim/Txt Qualifier for User Inputed Text Qualifiers

    # [string]$literalEscStr
    #region Literal Escape Character
    # Escape special characters (e.g. delimiter, text qualifier) in input string when processing 
    # [Parameter()][Alias("EscStrLiteralChar")][string]$StringIndicating_FollowingCharacterInInputString_IsLiteral=$null,
    $literalEscStr="$StringIndicating_FollowingCharacterInInputString_IsLiteral"
    #endregion Literal Escape Character

    # [bool]$ignLitEscStrIfInParamNm [bool]$ignLitEscStrIfInParamVal [bool]$ignLitEscStrIfInTxtQualStr [bool]$ignEscStrIfNxtCharNotSpec
    #region Ignore Literal Escape Condititions
    # Conditions when to ignore escape string
    # [Parameter()][Alias("IgnoreEscStrWithinParamName")][bool]$IgnoreNextCharacterIsLiteralIf_WithinParameterName=$null,
    # [Parameter()][Alias("IgnoreEscStrWithinParamVal")][bool]$IgnoreNextCharacterIsLiteralIf_WithinParameterValue=$null,
    # [Parameter()][Alias("IgnoreEscStrWithinTxtQualStr")][bool]$IgnoreNextCharacterIsLiteralIf_WithinTextQualifiedString=$null,
    # [Parameter()][Alias("IgnoreEscStrIfNxtCharNotSpec")][bool]$IgnoreEscapeStringIfNextCharacterIsNotSpecial=$null,
    $ignLitEscStrIfInParamNm=$IgnoreNextCharacterIsLiteralIf_WithinParameterName
    $ignLitEscStrIfInParamVal=$IgnoreNextCharacterIsLiteralIf_WithinParameterValue
    $ignLitEscStrIfInTxtQualStr=$IgnoreNextCharacterIsLiteralIf_WithinTextQualifiedString
    $ignEscStrIfNxtCharNotSpec=$IgnoreEscapeStringIfNextCharacterIsNotSpecial
    #endregion Ignore Literal Escape Condititions










    [string]$paramDelimsStartArr=@()
    [string]$paramDelimsEndArr=@()
    [string]$txtQualsStartArr=@()
    [string]$txtQualsEndArr=@()
    [string]$RemStrArrArr=@()

    #endregion Variables

    #region Delimiter and Qualifier parameter booleans to respective arrays

    if ($DelimiterFor_ParameterNameStart_IsSymbol_Space) {$paramDelimsStartArr+=' '}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_BackQuote) {$paramDelimsStartArr+='`'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Tilde) {$paramDelimsStartArr+='~'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Exclamation) {$paramDelimsStartArr+='!'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_AtOrAmpersat) {$paramDelimsStartArr+='@'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_PoundOrHash) {$paramDelimsStartArr+='#'} 
    if ($DelimiterFor_ParameterNameStart_IsSymbol_USD) {$paramDelimsStartArr+='$'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Percent) {$paramDelimsStartArr+='%'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Caret) {$paramDelimsStartArr+='^'}  
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Ampersand) {$paramDelimsStartArr+='&'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Asterisk) {$paramDelimsStartArr+='*'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_OpenParen) {$paramDelimsStartArr+='('}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_CloseParen) {$paramDelimsStartArr+=')'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Hyphen) {$paramDelimsStartArr+='-'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Underscore) {$paramDelimsStartArr+='_'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Equal) {$paramDelimsStartArr+='='}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Plus) {$paramDelimsStartArr+='+'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_OpenBracket) {$paramDelimsStartArr+='['}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_CloseBracket) {$paramDelimsStartArr+=']'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_OpenBrace) {$paramDelimsStartArr+='{'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_CloseBrace) {$paramDelimsStartArr+='}'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Comma) {$paramDelimsStartArr+=','}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Period) {$paramDelimsStartArr+='.'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_VerticalBarOrPipe) {$paramDelimsStartArr+='|'}        
    if ($DelimiterFor_ParameterNameStart_IsSymbol_BackSlash) {$paramDelimsStartArr+='\'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_ForwardSlash) {$paramDelimsStartArr+='/'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_SingleQuote) {$paramDelimsStartArr+="'"}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_DoubleQuote) {$paramDelimsStartArr+='"'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Colon) {$paramDelimsStartArr+=':'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_SemiColon) {$paramDelimsStartArr+=';'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_LessThanAngleBracket) {$paramDelimsStartArr+='<'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_GreaterThanAngleBracket) {$paramDelimsStartArr+='>'}
    if ($DelimiterFor_ParameterNameStart_IsSymbol_Question) {$paramDelimsStartArr+='?'}

    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Space) {$paramDelimsEndArr+=' '}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_BackQuote) {$paramDelimsEndArr+='`'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Tilde) {$paramDelimsEndArr+='~'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Exclamation) {$paramDelimsEndArr+='!'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_AtOrAmpersat) {$paramDelimsEndArr+='@'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_PoundOrHash) {$paramDelimsEndArr+='#'} 
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_USD) {$paramDelimsEndArr+='$'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Percent) {$paramDelimsEndArr+='%'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Caret) {$paramDelimsEndArr+='^'}  
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Ampersand) {$paramDelimsEndArr+='&'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Asterisk) {$paramDelimsEndArr+='*'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_OpenParen) {$paramDelimsEndArr+='('}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_CloseParen) {$paramDelimsEndArr+=')'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Hyphen) {$paramDelimsEndArr+='-'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Underscore) {$paramDelimsEndArr+='_'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Equal) {$paramDelimsEndArr+='='}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Plus) {$paramDelimsEndArr+='+'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_OpenBracket) {$paramDelimsEndArr+='['}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_CloseBracket) {$paramDelimsEndArr+=']'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_OpenBrace) {$paramDelimsEndArr+='{'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_CloseBrace) {$paramDelimsEndArr+='}'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Comma) {$paramDelimsEndArr+=','}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Period) {$paramDelimsEndArr+='.'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_VerticalBarOrPipe) {$paramDelimsEndArr+='|'}        
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_BackSlash) {$paramDelimsEndArr+='\'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_ForwardSlash) {$paramDelimsEndArr+='/'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_SingleQuote) {$paramDelimsEndArr+="'"}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_DoubleQuote) {$paramDelimsEndArr+='"'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Colon) {$paramDelimsEndArr+=':'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_SemiColon) {$paramDelimsEndArr+=';'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_LessThanAngleBracket) {$paramDelimsEndArr+='<'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_GreaterThanAngleBracket) {$paramDelimsEndArr+='>'}
    if ($DelimiterFor_ParameterNameEnd_IsSymbol_Question) {$paramDelimsEndArr+='?'}

    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_BackQuote) {$txtQualsStartArr+='`'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Tilde) {$txtQualsStartArr+='~'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Exclamation) {$txtQualsStartArr+='!'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_AtOrAmpersat) {$txtQualsStartArr+='@'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_PoundOrHash) {$txtQualsStartArr+='#'} 
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_USD) {$txtQualsStartArr+='$'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Percent) {$txtQualsStartArr+='%'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Caret) {$txtQualsStartArr+='^'}  
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Ampersand) {$txtQualsStartArr+='&'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Asterisk) {$txtQualsStartArr+='*'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_OpenParen) {$txtQualsStartArr+='('}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_CloseParen) {$txtQualsStartArr+=')'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Hyphen) {$txtQualsStartArr+='-'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Underscore) {$txtQualsStartArr+='_'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Equal) {$txtQualsStartArr+='='}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Plus) {$txtQualsStartArr+='+'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_OpenBracket) {$txtQualsStartArr+='['}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_CloseBracket) {$txtQualsStartArr+=']'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_OpenBrace) {$txtQualsStartArr+='{'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_CloseBrace) {$txtQualsStartArr+='}'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Comma) {$txtQualsStartArr+=','}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Period) {$txtQualsStartArr+='.'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_VerticalBarOrPipe) {$txtQualsStartArr+='|'}        
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_BackSlash) {$txtQualsStartArr+='\'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_ForwardSlash) {$txtQualsStartArr+='/'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_SingleQuote) {$txtQualsStartArr+="'"}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_DoubleQuote) {$txtQualsStartArr+='"'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Colon) {$txtQualsStartArr+=':'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_SemiColon) {$txtQualsStartArr+=';'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_LessThanAngleBracket) {$txtQualsStartArr+='<'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_GreaterThanAngleBracket) {$txtQualsStartArr+='>'}
    if ($DelimiterFor_TextQualifierStringStart_IsSymbol_Question) {$txtQualsStartArr+='?'}

    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_BackQuote) {$TxtQualsEndArr+='`'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Tilde) {$TxtQualsEndArr+='~'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Exclamation) {$TxtQualsEndArr+='!'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_AtOrAmpersat) {$TxtQualsEndArr+='@'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_PoundOrHash) {$TxtQualsEndArr+='#'} 
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_USD) {$TxtQualsEndArr+='$'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Percent) {$TxtQualsEndArr+='%'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Caret) {$TxtQualsEndArr+='^'}  
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Ampersand) {$TxtQualsEndArr+='&'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Asterisk) {$TxtQualsEndArr+='*'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_OpenParen) {$TxtQualsEndArr+='('}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_CloseParen) {$TxtQualsEndArr+=')'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Hyphen) {$TxtQualsEndArr+='-'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Underscore) {$TxtQualsEndArr+='_'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Equal) {$TxtQualsEndArr+='='}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Plus) {$TxtQualsEndArr+='+'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_OpenBracket) {$TxtQualsEndArr+='['}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_CloseBracket) {$TxtQualsEndArr+=']'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_OpenBrace) {$TxtQualsEndArr+='{'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_CloseBrace) {$TxtQualsEndArr+='}'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Comma) {$TxtQualsEndArr+=','}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Period) {$TxtQualsEndArr+='.'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_VerticalBarOrPipe) {$TxtQualsEndArr+='|'}        
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_BackSlash) {$TxtQualsEndArr+='\'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_ForwardSlash) {$TxtQualsEndArr+='/'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_SingleQuote) {$TxtQualsEndArr+="'"}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_DoubleQuote) {$TxtQualsEndArr+='"'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Colon) {$TxtQualsEndArr+=':'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_SemiColon) {$TxtQualsEndArr+=';'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_LessThanAngleBracket) {$TxtQualsEndArr+='<'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_GreaterThanAngleBracket) {$TxtQualsEndArr+='>'}
    if ($DelimiterFor_TextQualifierStringEnd_IsSymbol_Question) {$TxtQualsEndArr+='?'}

    if ($RemoveCharFromString_IsSymbol_Space) {$RemStrArrArr+=' '}
    if ($RemoveCharFromString_IsSymbol_BackQuote) {$RemStrArrArr+='`'}
    if ($RemoveCharFromString_IsSymbol_Tilde) {$RemStrArrArr+='~'}
    if ($RemoveCharFromString_IsSymbol_Exclamation) {$RemStrArrArr+='!'}
    if ($RemoveCharFromString_IsSymbol_AtOrAmpersat) {$RemStrArrArr+='@'}
    if ($RemoveCharFromString_IsSymbol_PoundOrHash) {$RemStrArrArr+='#'} 
    if ($RemoveCharFromString_IsSymbol_USD) {$RemStrArrArr+='$'}
    if ($RemoveCharFromString_IsSymbol_Percent) {$RemStrArrArr+='%'}
    if ($RemoveCharFromString_IsSymbol_Caret) {$RemStrArrArr+='^'}  
    if ($RemoveCharFromString_IsSymbol_Ampersand) {$RemStrArrArr+='&'}
    if ($RemoveCharFromString_IsSymbol_Asterisk) {$RemStrArrArr+='*'}
    if ($RemoveCharFromString_IsSymbol_OpenParen) {$RemStrArrArr+='('}
    if ($RemoveCharFromString_IsSymbol_CloseParen) {$RemStrArrArr+=')'}
    if ($RemoveCharFromString_IsSymbol_Hyphen) {$RemStrArrArr+='-'}
    if ($RemoveCharFromString_IsSymbol_Underscore) {$RemStrArrArr+='_'}
    if ($RemoveCharFromString_IsSymbol_Equal) {$RemStrArrArr+='='}
    if ($RemoveCharFromString_IsSymbol_Plus) {$RemStrArrArr+='+'}
    if ($RemoveCharFromString_IsSymbol_OpenBracket) {$RemStrArrArr+='['}
    if ($RemoveCharFromString_IsSymbol_CloseBracket) {$RemStrArrArr+=']'}
    if ($RemoveCharFromString_IsSymbol_OpenBrace) {$RemStrArrArr+='{'}
    if ($RemoveCharFromString_IsSymbol_CloseBrace) {$RemStrArrArr+='}'}
    if ($RemoveCharFromString_IsSymbol_Comma) {$RemStrArrArr+=','}
    if ($RemoveCharFromString_IsSymbol_Period) {$RemStrArrArr+='.'}
    if ($RemoveCharFromString_IsSymbol_VerticalBarOrPipe) {$RemStrArrArr+='|'}        
    if ($RemoveCharFromString_IsSymbol_BackSlash) {$RemStrArrArr+='\'}
    if ($RemoveCharFromString_IsSymbol_ForwardSlash) {$RemStrArrArr+='/'}
    if ($RemoveCharFromString_IsSymbol_SingleQuote) {$RemStrArrArr+="'"}
    if ($RemoveCharFromString_IsSymbol_DoubleQuote) {$RemStrArrArr+='"'}
    if ($RemoveCharFromString_IsSymbol_Colon) {$RemStrArrArr+=':'}
    if ($RemoveCharFromString_IsSymbol_SemiColon) {$RemStrArrArr+=';'}
    if ($RemoveCharFromString_IsSymbol_LessThanAngleBracket) {$RemStrArrArr+='<'}
    if ($RemoveCharFromString_IsSymbol_GreaterThanAngleBracket) {$RemStrArrArr+='>'}
    if ($RemoveCharFromString_IsSymbol_Question) {$RemStrArrArr+='?'}

    #endregion Delimiter and Qualifier parameter booleans to respective arrays

    $inParamNm=$false
    $inParamVal=$false

    $inTxtQual=$false
    $currTxtQualStart=$null
    $currTxtQualEnd=$null

    $continueOuterLoop=$false

    $nextCharIsLiteral=$false
    $nextCharIsLiteralLen="$literalEscStr".Length
    $currParamStartDelim=$null
    $currParamEndDelim=$null

    $currParamName=$null

    [int32]$indexPosition=0


    # Remove user specificed strings from input string
    if ($null -ne $removeStrs)
    {
        $remStrArr=@()
        $newInputString=$null
        $skipChar=$null
        $precedingChar=$null
        $counter=0
        $inTxtQual=$false
        foreach ($i in "$removeStrs".ToCharArray())
        {
            if ($i -eq '"' -and $counter -eq 0) {$inTxtQual=$true; $precedingChar=$i; continue}
            if ($i -eq '"' -and $counter -eq "$removeStrs".Length) {$inTxtQual=$false; $precedingChar=$i; continue}
            if ($counter -eq 0 -and !$inTxtQual) {$remStrArr+=$i; $precedingChar=$i; continue}

            if ($i -eq ' ' -and $inTxtQual) {$remStrArr+=$i}
            elseif ($i -eq ' ' -and $precedingChar -eq ',') {$remStrArr+=$i}
            elseif ($i -eq '"' -and $inTxtQual) {$remStrArr+=$i}
            elseif ($i -eq ',' -and $precedingChar -eq '\') {$remStrArr+=$i}
            elseif ($precedingChar -eq ',') {$remStrArr+=$i}
        }
        $counter=0
        foreach ($i in "$input".ToCharArray())
        {
            if ($removeStrs_SkipFirstChar -and $counter -eq 0) {continue}
            if ($removeStrs_SkipLastChar -and $counter -eq "$input".Length) {continue}

            foreach ($j in $remStrArr)
            {
                if ($i -eq $j) {$skipChar=$true}
            }

            if ($skipChar) {contine}
            else {$newInputString+=$i} 
        }
        $input=$newInputString
    }

    # Evaluate user strings for user indicated delimiters and text qualifiers.
    # DO STUFF




    for ($i=0; $i -le "$input".Length)
    {
        # Literal escape is useful (1) when inside text qualified string to escape a delimiter that would terminate the text qualified literal string or (2) when outside a text qualified string where you want to escape a delimiter that would trigger special meaning (e.g. start of parameter or start of qualified text). The next char will be literally interpreted.
        if (($inParamNm -and $ignLitEscStrIfInParamNm) `
            -or ($inParamVal -and $ignLitEscStrIfInParamVal) `
            -or ($inTxtQual -and $ignLitEscStrIfInTxtQualStr))
        {
            $nextCharIsLiteral=$false
        }
        elseif (!$nextCharIsLiteral -and ("$literalEscStr" -eq "$input".Substring($i,$nextCharIsLiteralLen)))
        {
            $nextCharIsLiteral=$true
            $nextCharIsSpecial=$false
            # If inside TextQualifer AND LiteralStringEscape is triggered, if char following LitStrEsc is not a special character, treat LitStrEsc as literal characters and not an escape string
            if ($ignEscStrIfNxtCharNotSpec -and $inTxtQual -and !$txtQualsStartEndMustMatch)
            {
                foreach ($j in $txtQualsStartArr)
                {
                    if ($j.Length -eq 1 -and $j -eq "$input".Substring($i+$nextCharIsLiteralLen,1))
                    {
                        $nextCharIsSpecial=$true
                        break
                    }
                    elseif ("$j".Length -gt 1 -and $j -eq ("$input".substring($i+$nextCharIsLiteralLen,"$j".Length)))
                    {
                        $nextCharIsSpecial=$true
                        break
                    }
                }
            }
            elseif ($ignEscStrIfNxtCharNotSpec -and $inTxtQual -and $txtQualsStartEndMustMatch)
            {
                if ("$currTxtQualEnd".Length -eq 1 -and ("$currTxtQualEnd" -eq "$input".ToCharArray()[$i+$nextCharIsLiteralLen]))
                {
                    $nextCharIsSpecial=$true
                }
                elseif ("$currTxtQualEnd".Length -gt 1 -and ("$currTxtQualEnd" -eq "$input".Substring($i+$nextCharIsLiteralLen,"$currTxtQualEnd".Length)))
                {
                    $nextCharIsSpecial=$true
                }  
            }            
            # If inside ParameterName and Not InTxtQualifer AND LiteralStringEscape is triggered, if char following LitStrEsc is not a special character, treat LitStrEsc as literal characters and not an escape string
            elseif ($ignEscStrIfNxtCharNotSpec -and $inParamNm -and !$paramDelimsStartEndMustMatch)
            {
                foreach ($j in "$paramDelimsEndArr")
                {
                    if ($j.Length -eq 1 -and $j -eq "$input".Substring($i+$nextCharIsLiteralLen,1))
                    {
                        $nextCharIsSpecial=$true
                        break
                    }
                    elseif ("$j".Length -gt 1 -and $j -eq ("$input".substring($i+$nextCharIsLiteralLen,"$j".Length)))
                    {
                        $nextCharIsSpecial=$true
                        break
                    }
                }
            }
            elseif ($ignEscStrIfNxtCharNotSpec -and $inParamNm -and $paramDelimsStartEndMustMatch)
            {
                if (("$currParamEndDelim".Length -eq 1) -and "$currParamEndDelim" -eq ("$input".ToCharArray()[$i+$nextCharIsLiteralLen]))
                {
                    $nextCharIsSpecial=$true
                }
                elseif (("$currParamEndDelim".Length -gt 1) -and ("$currParamEndDelim" -eq ("$input".Substring($i+$nextCharIsLiteralLen,"$currParamEndDelim".Length))))
                {
                    $nextCharIsSpecial=$true
                }
            }

            # If IgoreLiteralEscapeString if next char is NOT a special char AND the next char is not special, negate $nextCharIsLiteral and treat escape is regular string
            if ($ignEscStrIfNxtCharNotSpec -and !$nextCharIsSpecial) {$nextCharIsLiteral=$false}

            if ($nextCharIsLiteral) {$i=$i+$nextCharIsLiteralLen}
        }

        # Evaluate current position of $input to determine if start of literal string. If $nextCharIsLiteral, skip evaulation
        if (!$inTxtQual -and !$nextCharIsLiteral)
        {
            $continueOuterLoop=$false
            foreach ($j in $txtQualsStartArr)
            {
                if ($j.Length -eq 1 -and $j -eq "$input".Substring($i,1))
                {
                    $inTxtQual=$true
                    if ($txtQualsStartEndMustMatch) {$currTxtQualEnd="$currTxtQualStart"}
                    $i++
                    $continueOuterLoop=$true
                    break
                }
                elseif ("$j".Length -gt 1 -and $j -eq ("$input".substring($i,"$j".Length)))
                {
                    $inTxtQual=$true
                    if ($txtQualsStartEndMustMatch) {$currTxtQualEnd="$currTxtQualStart"}
                    $i=$i+"$j".Length
                    $continueOuterLoop=$true
                    break
                }
            }

            if ($continueOuterLoop) {continue}
        } 

        #region End Text Qualifier
        # Evaluate current position of $input to determine if end of literal string created by $inTxtQual. if $nextCharIsLiteral is true, it  
        if ($inTxtQual -and !$nextCharIsLiteral -and $txtQualsStartEndMustMatch)
        {
            if ("$currTxtQualEnd".Length -eq 1 -and ("$currTxtQualEnd" -eq "$input".ToCharArray()[$i]))
            {
                $inTxtQual=$false
                $i++
                continue
            }
            elseif ("$currTxtQualEnd".Length -gt 1 -and ("$currTxtQualEnd" -eq "$input".Substring($i,"$currTxtQualEnd".Length)))
            {
                $inTxtQual=$false
                $i=$i+"$currTxtQualEnd".Length
                continue
            }        
        }
        elseif ($inTxtQual -and !$nextCharIsLiteral -and !$txtQualsStartEndMustMatch)
        {
            $continueOuterLoop=$false
            foreach ($j in $txtQualsEndArr)
            {
                if ($j.Length -eq 1 -and $j -eq "$input".Substring($i,1))
                {
                    $inTxtQual=$false
                    $currTxtQualEnd=$null
                    $currTxtQualStart=$null
                    $i++
                    $continueOuterLoop=$true
                    break
                }
                elseif ("$j".Length -gt 1 -and $j -eq ("$input".substring($i,"$j".Length)))
                {
                    $inTxtQual=$false
                    $currTxtQualEnd=$null
                    $currTxtQualStart=$null
                    $i=$i+"$j".Length
                    $continueOuterLoop=$true
                    break
                }
            }

            if ($continueOuterLoop) {continue}
        }
        #endregion End Text Qualifier

        # After $inTxtQual blocks are evaluated, $nextCharIsLiteral will no longer affect $inTxtQual until next loop. As such, the rest of the logic in the outer loop will treat $inTxtQual and $nextCharAsLiteral as the same. That is, the next charcter will be viewed as a literal. So, to simplify, $nextCharIsLiteral will be used to represent both. However, when the remainder of the loop is finsihed and ready to move on, $nextCharIsLiteral will need to be made $false so that it can be re-evaluated at the start of the loop.
        if ($inTxtQual) {$nextCharIsLiteral=$true}

        # Enter if not inside (ParamName OR ParamVal) AND the NextCharIsLiteral.
        # $nextCharIsLiteral is irrelevant since it can't be used to signal start of parameter and, since you are not inside a ParamName or ParamVal, the LiteralChar cannot be added to the value of any output string. It was a pointless literal escape.
        if (!$inParamNm -and !$inParamVal -and $nextCharIsLiteral)
        {
            $nextCharIsLiteral=$false
            $i++
            continue
        }
        # Enter block if not in (ParamName or ParamVal) AND NextChar IS NOT literal. Block will evaluate whether it is the start of a new parameter
        elseif (!$inParamNm -and !$inParamVal -and !$nextCharIsLiteral)
        {
            $continueOuterLoop=$false
            foreach ($j in "$paramDelimsStartArr")
            {
                if ($j.Length -eq 1 -and $j -eq "$input".Substring($i,1))
                {
                    $currParamStartDelim="$j"
                    $inParamNm=$true
                    if ($paramDelimsStartEndMustMatch) {$currParamEndDelim="$currParamStartDelim"}
                    $continueOuterLoop=$true
                    $i++
                    break
                }
                elseif ("$j".Length -gt 1 -and $j -eq ("$input".substring($i,"$j".Length)))
                {
                    $currParamStartDelim="$j"
                    if ($paramDelimsStartEndMustMatch) {$currParamEndDelim="$currParamStartDelim"}
                    $inParamNm=$true
                    $continueOuterLoop=$true
                    $i=$i+"$j".Length
                    break
                }
            }
            if ($continueOuterLoop) {continue}
        }
        elseif ($inParamNm -and !$nextCharIsLiteral -and $paramDelimsStartEndMustMatch)
        {
            if (("$currParamEndDelim".Length -eq 1) -and "$currParamEndDelim" -eq ("$input".ToCharArray()[$i]))
            {
                $inParamNm=$false
                $inParamVal=$true
                $i++
                continue
            }
            elseif (("$currParamEndDelim".Length -gt 1) -and ("$currParamEndDelim" -eq ("$input".Substring($i,"$currParamEndDelim".Length))))
            {
                $inParamNm=$false
                $inParamVal=$true
                $i++
                continue
            }
        }
        elseif ($inParamNm -and !$nextCharIsLiteral -and !$paramDelimsStartEndMustMatch)
        {

        }

        # If $inParamName and previous logic did not find delimiter to end $inParamName, add next character to $currParamName       
        if ($inParamNm)
        {
            $currParamName+=$input.ToCharArray()[$i]
            $nextCharIsLiteral=$false
            $i++
        }

        # Check to see if character is start of new parameter. If so, end $inParamterValue
        if ($inParamVal -and !$nextCharIsLiteral)
        {
            # $continueOuterLoop=$false
            # foreach ($j in "$paramDelimsStartArr")
            # {
            #     if ($j.Length -eq 1 -and $j -eq "$input".Substring($i,1))
            #     {
            #         $currParamStartDelim="$j"
            #         $inParamNm=$true
            #         if ($paramDelimsStartEndMustMatch) {$currParamEndDelim="$currParamStartDelim"}
            #         $continueOuterLoop=$true
            #         $i++
            #         break
            #     }
            #     elseif ("$j".Length -gt 1 -and $j -eq ("$input".substring($i,"$j".Length)))
            #     {
            #         $currParamStartDelim="$j"
            #         if ($paramDelimsStartEndMustMatch) {$currParamEndDelim="$currParamStartDelim"}
            #         $inParamNm=$true
            #         $continueOuterLoop=$true
            #         $i=$i+"$j".Length
            #         break
            #     }
            # }
            # if ($continueOuterLoop) {continue}
        }

        if ($inParamVal)
        {

        }

    }

    # Combine into arrays and return arrays according to input parameters

    # Additional work: validate arrays with delimiters so multi-charcter delim entered by user is negated by single character delimiters with same chars as in multi-char delim

    $precedingCharIsSpace=$false
    $inParameter=$false
    $inDoubleQuote=$false
    $currParameter=$null
    [string[]]$parameterArray=@()

    foreach ($i in $InputString.ToCharArray())
    {
        if ($i -eq " " -and $inParameter)
        {
            $inParameter=$false
            $parameterArray+=,$currParameter
            $currParameter=""
            $precedingCharIsSpace=$true
        }
        elseif ($i -eq "-" -and !$inDoubleQuote -and $precedingCharIsSpace)
        {
            $inParameter=$true
            #$currParameter+=$i
            $precedingCharIsSpace=$false
        }
        elseif ($inParameter)
        {
            $currParameter+=$i
        }
        elseif ($i -eq ' ' -and !$inDoubleQuote)
        {
            $precedingCharIsSpace=$true
        }
    }
    Write-Output $parameterArray
}