# (C) Copyright 2020. Brian R. Preston. All Rights Reserved

# Assumes, once the first parameter is identified through start-end delimiters, the value of the parameter immediately follows it and is terminated by the next parameter. This script does not assume the first character of the string is a parameter; it waits for the delimiter indicating the start of a parameter name.
function Get-MatchedParameterNameAndValuesFromString_ReturnArray
{
    [CmdletBinding()]
    param
    (
        #region Parameters
        
        # Allow user to enter parameters in this command interactively
        [Parameter()][Alias("Interactive")][string]$EnterParamaters_InThisCommand_WithInteractivePrommpts=$false,

        # Input String
        [Parameter(Mandatory=$true)][Alias("Input")][string]$InputString,

        # Values to return
        [Parameter()][Alias("RetParamNames")][bool]$ReturnArrayOf_ParameterNames=$true,
        [Parameter()][Alias("RetParamValues")][bool]$ReturnArrayOf_ParameterValues=$true,

        # Sorting prefence of array output
        [Parameter()][Alias("SortParamNames")][bool]$SortOutput_ParameterNames=$false,
        [Parameter()][Alias("SortParamValues")][bool]$SortOutput_ParameterValues=$false,
        [Parameter()][Alias("SortParamNameTopOrder")][bool]$SortParameterNameThenParameterValues=$True,

        # Guess delimiters, parameter names, parameter values in not user inputted
        # If user partially enters these parameters, the rest will be guessed. 
        [Parameter()][Alias("BestGuess")][bool]$BestGuess_DelimitersAndLiteralQualifiersIn_InputString=$null,

        # Are keywords and value free of spaces
        [Parameter()][Alias("ParamNameNoSpaces")][bool]$ParameterNamesIn_InputString_HaveNoSpaces=$null,
        [Parameter()][Alias("ParamValueNoSpaces")][bool]$ParameterValuesIn_InputString_HaveNoSpaces=$null,

        # Universal delimiters and text qualifiers for this command
        [Parameter()][Alias("UnivDelimInThisCommand")][string]$Universal_DelimiterSeparating_MultipleDelimitersOrLiteralQualifiers_InThisCommand,
        [Parameter()][Alias("UnivTxtQualInThisCommand")][string]$Universal_LiteralQualifierFor_MultipleDelimitersOrLiteralQualifiers_InThisCommand,
        [Parameter()][Alias("UnivEscInThisCommand")][string]$Universal_EscapeCharacterFor_MultipleDelimitersOrLiteralQualifiers_InThisCommand,

# Universal delimiters and text qualifiers for this command
[Parameter()][Alias("UnivDelimInInputStr")][string]$Universal_DelimiterSeparating_MultipleDelimitersOrLiteralQualifiersIn_InputString,
[Parameter()][Alias("UnivTxtQualInInputStr")][string]$Universal_LiteralQualifierFor_MultipleDelimitersOrLiteralQualifiersIn_InputString,
[Parameter()][Alias("UnivEscInInputStr")][string]$Universal_EscapeCharacterFor_MultipleDelimitersOrLiteralQualifiersIn_InputString,

        # Text qualifiers (intrepet contents as literal) for start and end of a string; Must start-end delimiters match
        [Parameter()][Alias("LitQualStart")][string]$LiteralQualifierStringsFor_StartOfLiteralStringIn_InputString=$null,
        [Parameter()][Alias("LitQualEnd")][string]$LiteralQualifierStringsFor_EndOfLiteralStringIn_InputString=$null,
        [Parameter()][Alias("LitQualStartEndMatch")][bool]$LiteralQualifierStringsFor_StartAndEndOfLiteralString_MustMatch=$null,

        # Local delimiter, text qualifer, and escape string (singular) for literal qualifiers in the input string
        [Parameter()][Alias("UnivDelimInThisCommand")][string]$Local_DelimiterSeparating_MultipleDelimitersOrLiteralQualifiersIn_LiteralQualifierStringsForStartAndEndOfLiteralString_InThisCommand,

        # Spaces are delimiters unless escaped or text qualified
        [Parameter()][Alias("SpacesAreDelimExcptIfEsc")][bool]$TreatSpaceAsDelimiter_UnlessEscapedOrQualifiedLiteralStringIn_InputString=$null,

        # Escape special characters (e.g. delimiter, text qualifier) in input string when processing 
        [Parameter()][Alias("EscStrForLitrlChar")][string]$Universal_StringsIndicating_FollowingCharacterIsLiteralIn_InputString=$null,

        # If two or more escape strings are preceded by and escape string, treat as single escape string
        # Default is $false; If an escape string follows another, the first character in the second escape string will be a literal
        [Parameter()][Alias("DblEscStrIsOneEscStr")][bool]$TreatDoubleEscapeStringsOrCharactersAs_SingleEscapeStringOrCharacter=$false,

        # Remove strings from input string; processed first 
        [Parameter()][Alias("RemStrFromInput")][string]$StringsToRemoveFrom_InputString=$null,
        [Parameter()][Alias("RemStrFromInputDelim")][string]$Local_DelimiterStringSeperating_StringsToRemoveFrom_InputString_InThisCommand=$null,
        [Parameter()][Alias("RemStrFromInputLitQual")][string]$Local_LiteralQualifierStringFor_StringsToRemoveFrom_InputString=$null,
        [Parameter()][Alias("RemStrFromInputEscStr")][string]$Local_EscStrFor_StringsToRemoveFrom_InputString=$null,
        [Parameter()][Alias("RemStrSkipFirst")][bool]$IfRemovingStrings_SkipFirstCharacter=$null,
        [Parameter()][Alias("RemStrSkipLast")][bool]$IfRemovingStrings_SkipLastCharacter=$null,          
        
        # Delimiters for start and end of parameter names; Must start-end delimiters match
        [Parameter()][Alias("ParamStartDelim")][String]$DelimiterStringsFor_ParameterNameStart_InInputString=$null,
        [Parameter()][Alias("ParamEndDelim")][String]$DelimiterStringsFor_ParameterNameEnd_InInputString=$null,
        [Parameter()][Alias("ParamDelimsStartEndMatch")][string]$DelimitersFor_ParameterNameStartAndEnd_MustMatch=$null,

        # Delimiter and text qualifer to separate multiple user delimiters of parameter names
        [Parameter()][Alias("ParamMultiDelims_Delim")][String]$DelimiterSeparating_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand=$null,
        [Parameter()][Alias("ParamMultiDelims_LitQual")][String]$LiteralQualifierFor_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand=$null,
        [Parameter()][Alias("ParamMultiDelims_EscStr")][string]$LocalEscapeStringFor_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand=$null, 



        # Conditions when to ignore escape string
        [Parameter()][Alias("IgnoreEscStrWithinParamName")][bool]$IgnoreNextCharacterIsLiteralIf_WithinParameterName=$null,
        [Parameter()][Alias("IgnoreEscStrWithinParamVal")][bool]$IgnoreNextCharacterIsLiteralIf_WithinParameterValue=$null,
        [Parameter()][Alias("IgnoreEscStrWithinLitQualStr")][bool]$IgnoreNextCharacterIsLiteralIf_WithinQualifiedLiteralStringString=$null,
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

        [Parameter()][Alias("LitQualiferS_BkQuote")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_BackQuote=$null,
        [Parameter()][Alias("LitQualiferS_Tilde")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Tilde=$null,
        [Parameter()][Alias("LitQualiferS_Exclamation")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Exclamation=$null,
        [Parameter()][Alias("LitQualiferS_At")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_AtOrAmpersat=$null,
        [Parameter()][Alias("LitQualiferS_Hash")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_PoundOrHash=$null, 
        [Parameter()][Alias("LitQualiferS_USD")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_USD=$null,
        [Parameter()][Alias("LitQualiferS_Pct")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Percent=$null,
        [Parameter()][Alias("LitQualiferS_Caret")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Caret=$null,  
        [Parameter()][Alias("LitQualiferS_Ampersand")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Ampersand=$null,
        [Parameter()][Alias("LitQualiferS_Asterisk")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Asterisk=$null,
        [Parameter()][Alias("LitQualiferS_OpenParen")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_OpenParen=$null,
        [Parameter()][Alias("LitQualiferS_CloseParen")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_CloseParen=$null,
        [Parameter()][Alias("LitQualiferS_Hypen")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Hyphen=$null,
        [Parameter()][Alias("LitQualiferS_Underscore")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Underscore=$null,
        [Parameter()][Alias("LitQualiferS_Equal")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Equal=$null,
        [Parameter()][Alias("LitQualiferS_Plus")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Plus=$null,
        [Parameter()][Alias("LitQualiferS_OpenBracket")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_OpenBracket=$null,
        [Parameter()][Alias("LitQualiferS_CloseBracket")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_CloseBracket=$null,
        [Parameter()][Alias("LitQualiferS_OpenBrace")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_OpenBrace=$null,
        [Parameter()][Alias("LitQualiferS_CloseBrace")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_CloseBrace=$null,
        [Parameter()][Alias("LitQualiferS_Comma")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Comma=$null,
        [Parameter()][Alias("LitQualiferS_Period")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Period=$null,
        [Parameter()][Alias("LitQualiferS_Pipe")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_VerticalBarOrPipe=$null,        
        [Parameter()][Alias("LitQualiferS_BkSlash")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_BackSlash=$null,
        [Parameter()][Alias("LitQualiferS_FwdSlash")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_ForwardSlash=$null,
        [Parameter()][Alias("LitQualiferS_SnglQuote")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_SingleQuote=$null,
        [Parameter()][Alias("LitQualiferS_DblQuote")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_DoubleQuote=$null,
        [Parameter()][Alias("LitQualiferS_Color")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Colon=$null,
        [Parameter()][Alias("LitQualiferS_SemiColon")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_SemiColon=$null,
        [Parameter()][Alias("LitQualiferS_LessThan")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_LessThanAngleBracket=$null,
        [Parameter()][Alias("LitQualiferS_GreaterThan")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_GreaterThanAngleBracket=$null,
        [Parameter()][Alias("LitQualiferS_Question")][bool]$DelimiterFor_LiteralQualifierStringStart_IsSymbol_Question=$null,

        #endregion Delimiters for Start of Text Qualifier

        #region Delimiters for End of Text Qualifier

        [Parameter()][Alias("LitQualiferE_BkQuote")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_BackQuote=$null,
        [Parameter()][Alias("LitQualiferE_Tilde")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Tilde=$null,
        [Parameter()][Alias("LitQualiferE_Exclamation")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Exclamation=$null,
        [Parameter()][Alias("LitQualiferE_At")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_AtOrAmpersat=$null,
        [Parameter()][Alias("LitQualiferE_Hash")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_PoundOrHash=$null, 
        [Parameter()][Alias("LitQualiferE_USD")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_USD=$null,
        [Parameter()][Alias("LitQualiferE_Pct")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Percent=$null,
        [Parameter()][Alias("LitQualiferE_Caret")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Caret=$null,  
        [Parameter()][Alias("LitQualiferE_Ampersand")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Ampersand=$null,
        [Parameter()][Alias("LitQualiferE_Asterisk")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Asterisk=$null,
        [Parameter()][Alias("LitQualiferE_OpenParen")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_OpenParen=$null,
        [Parameter()][Alias("LitQualiferE_CloseParen")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_CloseParen=$null,
        [Parameter()][Alias("LitQualiferE_Hypen")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Hyphen=$null,
        [Parameter()][Alias("LitQualiferE_Underscore")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Underscore=$null,
        [Parameter()][Alias("LitQualiferE_Equal")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Equal=$null,
        [Parameter()][Alias("LitQualiferE_Plus")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Plus=$null,
        [Parameter()][Alias("LitQualiferE_OpenBracket")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_OpenBracket=$null,
        [Parameter()][Alias("LitQualiferE_CloseBracket")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_CloseBracket=$null,
        [Parameter()][Alias("LitQualiferE_OpenBrace")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_OpenBrace=$null,
        [Parameter()][Alias("LitQualiferE_CloseBrace")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_CloseBrace=$null,
        [Parameter()][Alias("LitQualiferE_Comma")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Comma=$null,
        [Parameter()][Alias("LitQualiferE_Period")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Period=$null,
        [Parameter()][Alias("LitQualiferE_Pipe")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_VerticalBarOrPipe=$null,        
        [Parameter()][Alias("LitQualiferE_BkSlash")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_BackSlash=$null,
        [Parameter()][Alias("LitQualiferE_FwdSlash")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_ForwardSlash=$null,
        [Parameter()][Alias("LitQualiferE_SnglQuote")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_SingleQuote=$null,
        [Parameter()][Alias("LitQualiferE_DblQuote")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_DoubleQuote=$null,
        [Parameter()][Alias("LitQualiferE_Color")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Colon=$null,
        [Parameter()][Alias("LitQualiferE_SemiColon")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_SemiColon=$null,
        [Parameter()][Alias("LitQualiferE_LessThan")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_LessThanAngleBracket=$null,
        [Parameter()][Alias("LitQualiferE_GreaterThan")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_GreaterThanAngleBracket=$null,
        [Parameter()][Alias("LitQualiferE_Question")][bool]$DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Question=$null,

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

    #region Parameter Variables

    # Allow user to enter parameters in this command interactively
    [Parameter()][Alias("Interactive")][string]$EnterParamaters_InThisCommand_WithInteractivePrommpts=$false,

    # [string]$input
    #region Input String: 
    # [Parameter(Mandatory=$true)][Alias("Input")][string]$InputString,
    $input="$InputString" 
    #endregion Input String


    # [string[]]$retNames [string[]]$retVals
    #region Return Values: 
    # Values to return
    # [Parameter()][Alias("RetParamNames")][bool]$ReturnArrayOf_ParameterNames=$true,
    # [Parameter()][Alias("RetParamValues")][bool]$ReturnArrayOf_ParameterValues=$true,
    $retNames=$ReturnArrayOf_ParameterNames
    $retVals=$ReturnArrayOf_ParameterValues
    #endregion Return Values

    # [bool]$sortParamNames [bool]$sortParamVals [bool]$SortParamNamesTop
    #region Return Sort Preferences
    # Sorting prefence of array output
    # [Parameter()][Alias("SortParamNames")][bool]$SortOutput_ParameterNames=$false,
    # [Parameter()][Alias("SortParamValues")][bool]$SortOutput_ParameterValues=$false,
    # [Parameter()][Alias("SortParamNameTopOrder")][bool]$SortParameterNameThenParameterValues=$True,
    $sortParamNames=$SortOutput_ParameterNames
    $sortParamVals=$SortOutput_ParameterValues
    $SortParamNamesTop=$SortParameterNameThenParameterValues
    #endregion Return Sort Preferences

    # [bool]$guess
    #region Guess Delimiters/Content: 
    # Guess delimiters, parameter names, parameter values
    # [Parameter()][Alias("BestGuess")][bool]$BestGuess_DelimitersAndLiteralQualifiersIn_InputString=$null,
    $guess=$BestGuess_DelimitersAndLiteralQualifiersIn_InputString
    #endregion Guess Delimiters/Content

    # [bool]$namesNoSpaces [bool]$valuesNoSpaces
    #region Are There Non-delimiting Spaces: 
    # Are keywords and value free of spaces
    # [Parameter()][Alias("ParamNameNoSpaces")][bool]$ParameterNamesIn_InputString_HaveNoSpaces=$null,
    # [Parameter()][Alias("ParamValueNoSpaces")][bool]$ParameterValuesIn_InputString_HaveNoSpaces=$null,
    $namesNoSpaces=$ParameterNamesIn_InputString_HaveNoSpaces
    $valuesNoSpaces=$ParameterValuesIn_InputString_HaveNoSpaces
    #endregion Are There Non-delimiting Spaces

    # Universal delimiters and text qualifiers for this command
    [Parameter()][Alias("UnivDelimInThisCommand")][string]$Universal_DelimiterSeparating_MultipleDelimitersOrLiteralQualifiers_InThisCommand,
    [Parameter()][Alias("UnivTxtQualInThisCommand")][string]$Universal_LiteralQualifierFor_MultipleDelimitersOrLiteralQualifiers_InThisCommand,
    [Parameter()][Alias("UnivEscInThisCommand")][string]$Universal_EscapeCharacterFor_MultipleDelimitersOrLiteralQualifiers_InThisCommand,


    # [string]$LitQualsStart [string]$LitQualsEnd
    #region Text Qualifiers for Literal String
    # Text qualifiers (intrepet contents as literal) for start and end of a string; Must start-end delimiters match
    # [Parameter()][Alias("LitQualStart")][string]$LiteralQualifierStringsFor_StartOfLiteralStringIn_InputString=$null,
    # [Parameter()][Alias("LitQualEnd")][string]$LiteralQualifierStringsFor_EndOfLiteralStringIn_InputString=$null,
    # [Parameter()][Alias("LitQualStartEndMatch")][bool]$LiteralQualifierStringsFor_StartAndEndOfLiteralString_MustMatch=$null,
    $LitQualsStart="$LiteralQualifierStringsFor_StartOfLiteralStringIn_InputString"
    $LitQualsEnd="$LiteralQualifierStringsFor_EndOfLiteralStringIn_InputString"
    $LitQualsStartEndMustMatch=$LiteralQualifierStringsFor_StartAndEndOfLiteralString_MustMatch    
    #endregion Text Qualifiers for Literal String
s
    # [bool]$spacesAreDelimExcptEsc
    #region Spaces Are Delimiters Except When Escaped: 
    # Spaces are delimiters unless escaped or text qualified
    # [Parameter()][Alias("SpacesAreDelimExcptIfEsc")][bool]$TreatSpaceAsDelimiter_UnlessEscapedOrQualifiedLiteralStringIn_InputString=$null,
    $spacesAreDelimExcptEsc=$TreatSpaceAsDelimiter_UnlessEscapedOrQualifiedLiteralStringIn_InputString
    #endregion Spaces Are Delimiters Except When Escaped

    # [string]$literalEscStr
    #region Literal Escape Character
    # Escape special characters (e.g. delimiter, text qualifier) in input string when processing 
    # [Parameter()][Alias("EscStrForLitrlChar")][string]$Universal_StringsIndicating_FollowingCharacterIsLiteralIn_InputString=$null,
    $literalEscStr="$Universal_StringsIndicating_FollowingCharacterIsLiteralIn_InputString"
    #endregion Literal Escape Character

    # [bool]$DblEscStrIsOne
    #region Double Escape Strings
    # If two or more escape strings are preceded by and escape string, treat as single escape string
    # Default is $false; If an escape string follows another, the first character in the second escape string will be a literal
    # [Parameter()][Alias("DblEscStrIsOneEscStr")][bool]$TreatDoubleEscapeStringsOrCharactersAs_SingleEscapeStringOrCharacter=$false,
    $DblEscStrIsOne=$TreatDoubleEscapeStringsOrCharactersAs_SingleEscapeStringOrCharacter
    #endregion Double Escape Strings

    # [string]$removeStrs [char]$removeStrs_InputDelimChar [bool]$removeStrs_SkipFirstChar [bool]$removeStrs_SkipLastChar
    #region Remove content from input string: 
    # Remove strings from input string; processed first 
    # [Parameter()][Alias("RemStrFromInput")][string]$StringsToRemoveFrom_InputString=$null,
    # [Parameter()][Alias("RemStrFromInputDelim")][string]$Local_DelimiterStringSeperating_StringsToRemoveFrom_InputString_InThisCommand=$null,
    # [Parameter()][Alias("RemStrFromInputLitQual")][string]$Local_LiteralQualifierStringFor_StringsToRemoveFrom_InputString=$null,
    # [Parameter()][Alias("RemStrFromInputEscStr")][string]$Local_EscStrFor_StringsToRemoveFrom_InputString=$null,
    # [Parameter()][Alias("RemStrSkipFirst")][bool]$IfRemovingStrings_SkipFirstCharacter=$null,
    # [Parameter()][Alias("RemStrSkipLast")][bool]$IfRemovingStrings_SkipLastCharacter=$null,  
    $removeStrs=$StringsToRemoveFrom_InputString
    $removeStrs_InputDelimChar=$DelimiterCharacterFor_StringsToRemoveFrom_InputString
    $removeStrs_LitQual=$LiteralQualifierForUserInputted_StringsToRemoveFrom_InputString
    $removeStrs_EscChar=$Local_EscStrFor_StringsToRemoveFrom_InputString
    $removeStrs_SkipFirstChar=$IfRemovingStrings_SkipFirstCharacter
    $removeStrs_SkipLastChar=$IfRemovingStrings_SkipLastCharacter
    #endregion Remove content from input string

    # [string]$paramDelimsStart [string]$paramDelimsEnd
    #region Delimiters for Param Names Start-End 
    # Delimiters for start and end of parameter names; Must start-end delimiters match
    # [Parameter()][Alias("ParamStartDelim")][String]$DelimiterStringsFor_ParameterNameStart_InInputString=$null,
    # [Parameter()][Alias("ParamEndDelim")][String]$DelimiterStringsFor_ParameterNameEnd_InInputString=$null,
        # [Parameter()][Alias("ParamDelimsStartEndMatch")][string]$DelimitersFor_ParameterNameStartAndEnd_MustMatch=$null,
    $paramDelimsStart="$DelimiterStringsFor_ParameterNameStart_InInputString"
    $paramDelimsEnd="$DelimiterStringsFor_ParameterNameEnd_InInputString"
    $paramDelimsStartEndMustMatch=$DelimitersFor_ParameterNameStartAndEnd_MustMatch    
    #endregion Delimiters for Param Names Start-End

    # [string]$paramDelimOfDelims [string]$paramDelimsLitQual [string]$paramDelimsEscStr [string]$paramDelimsStartEndMustMatch
    #region Delim/Txt Qualifier for user inputted delims for Param Names: 
    # Delimiter and text qualifer to separate multiple user delimiters of parameter names
    # [Parameter()][Alias("ParamMultiDelims_Delim")][String]$DelimiterSeparating_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand=$null,
    # [Parameter()][Alias("ParamMultiDelims_LitQual")][String]$LiteralQualifierFor_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand=$null,
    # [Parameter()][Alias("ParamMultiDelims_EscStr")][string]$LocalEscapeStringFor_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand=$null,
    $paramDelimOfDelims="$DelimiterSeparating_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand"
    $paramDelimsLitQual="$LiteralQualifierFor_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand"
    $paramDelimsEscStr=$LocalEscapeStringFor_DelimiterStringsFor_ParameterNameStart_InInputString_InThisCommand
    #endregion Delim/Txt Qualifier for user inputted delims for Param Names





    # [bool]$ignLitEscStrIfInParamNm [bool]$ignLitEscStrIfInParamVal [bool]$ignLitEscStrIfInLitQualStr [bool]$ignEscStrIfNxtCharNotSpec
    #region Ignore Literal Escape Condititions
    # Conditions when to ignore escape string
    # [Parameter()][Alias("IgnoreEscStrWithinParamName")][bool]$IgnoreNextCharacterIsLiteralIf_WithinParameterName=$null,
    # [Parameter()][Alias("IgnoreEscStrWithinParamVal")][bool]$IgnoreNextCharacterIsLiteralIf_WithinParameterValue=$null,
    # [Parameter()][Alias("IgnoreEscStrWithinLitQualStr")][bool]$IgnoreNextCharacterIsLiteralIf_WithinQualifiedLiteralStringString=$null,
    # [Parameter()][Alias("IgnoreEscStrIfNxtCharNotSpec")][bool]$IgnoreEscapeStringIfNextCharacterIsNotSpecial=$null,
    $ignLitEscStrIfInParamNm=$IgnoreNextCharacterIsLiteralIf_WithinParameterName
    $ignLitEscStrIfInParamVal=$IgnoreNextCharacterIsLiteralIf_WithinParameterValue
    $ignLitEscStrIfInLitQualStr=$IgnoreNextCharacterIsLiteralIf_WithinQualifiedLiteralStringString
    $ignEscStrIfNxtCharNotSpec=$IgnoreEscapeStringIfNextCharacterIsNotSpecial
    #endregion Ignore Literal Escape Condititions

    #endregion Parameter Variables

    #region Arrays for user specified delimiters, text qualifiers, and characters to remove from input string
    [string]$RemoveStrArr=@()
    [string]$paramDelimsStartArr=@()
    [string]$paramDelimsEndArr=@()
    [string]$LitQualsStartArr=@()
    [string]$LitQualsEndArr=@()
    #endregion Arrays for user specified delimiters, text qualifiers, and characters to remove from input string

    #endregion Variables

    #region Assign Delimiter and Qualifier parameter booleans to respective arrays

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

    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_BackQuote) {$LitQualsStartArr+='`'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Tilde) {$LitQualsStartArr+='~'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Exclamation) {$LitQualsStartArr+='!'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_AtOrAmpersat) {$LitQualsStartArr+='@'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_PoundOrHash) {$LitQualsStartArr+='#'} 
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_USD) {$LitQualsStartArr+='$'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Percent) {$LitQualsStartArr+='%'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Caret) {$LitQualsStartArr+='^'}  
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Ampersand) {$LitQualsStartArr+='&'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Asterisk) {$LitQualsStartArr+='*'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_OpenParen) {$LitQualsStartArr+='('}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_CloseParen) {$LitQualsStartArr+=')'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Hyphen) {$LitQualsStartArr+='-'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Underscore) {$LitQualsStartArr+='_'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Equal) {$LitQualsStartArr+='='}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Plus) {$LitQualsStartArr+='+'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_OpenBracket) {$LitQualsStartArr+='['}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_CloseBracket) {$LitQualsStartArr+=']'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_OpenBrace) {$LitQualsStartArr+='{'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_CloseBrace) {$LitQualsStartArr+='}'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Comma) {$LitQualsStartArr+=','}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Period) {$LitQualsStartArr+='.'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_VerticalBarOrPipe) {$LitQualsStartArr+='|'}        
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_BackSlash) {$LitQualsStartArr+='\'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_ForwardSlash) {$LitQualsStartArr+='/'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_SingleQuote) {$LitQualsStartArr+="'"}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_DoubleQuote) {$LitQualsStartArr+='"'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Colon) {$LitQualsStartArr+=':'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_SemiColon) {$LitQualsStartArr+=';'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_LessThanAngleBracket) {$LitQualsStartArr+='<'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_GreaterThanAngleBracket) {$LitQualsStartArr+='>'}
    if ($DelimiterFor_LiteralQualifierStringStart_IsSymbol_Question) {$LitQualsStartArr+='?'}

    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_BackQuote) {$LitQualsEndArr+='`'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Tilde) {$LitQualsEndArr+='~'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Exclamation) {$LitQualsEndArr+='!'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_AtOrAmpersat) {$LitQualsEndArr+='@'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_PoundOrHash) {$LitQualsEndArr+='#'} 
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_USD) {$LitQualsEndArr+='$'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Percent) {$LitQualsEndArr+='%'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Caret) {$LitQualsEndArr+='^'}  
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Ampersand) {$LitQualsEndArr+='&'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Asterisk) {$LitQualsEndArr+='*'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_OpenParen) {$LitQualsEndArr+='('}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_CloseParen) {$LitQualsEndArr+=')'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Hyphen) {$LitQualsEndArr+='-'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Underscore) {$LitQualsEndArr+='_'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Equal) {$LitQualsEndArr+='='}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Plus) {$LitQualsEndArr+='+'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_OpenBracket) {$LitQualsEndArr+='['}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_CloseBracket) {$LitQualsEndArr+=']'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_OpenBrace) {$LitQualsEndArr+='{'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_CloseBrace) {$LitQualsEndArr+='}'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Comma) {$LitQualsEndArr+=','}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Period) {$LitQualsEndArr+='.'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_VerticalBarOrPipe) {$LitQualsEndArr+='|'}        
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_BackSlash) {$LitQualsEndArr+='\'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_ForwardSlash) {$LitQualsEndArr+='/'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_SingleQuote) {$LitQualsEndArr+="'"}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_DoubleQuote) {$LitQualsEndArr+='"'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Colon) {$LitQualsEndArr+=':'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_SemiColon) {$LitQualsEndArr+=';'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_LessThanAngleBracket) {$LitQualsEndArr+='<'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_GreaterThanAngleBracket) {$LitQualsEndArr+='>'}
    if ($DelimiterFor_LiteralQualifierStringEnd_IsSymbol_Question) {$LitQualsEndArr+='?'}

    if ($RemoveCharFromString_IsSymbol_Space) {$RemoveStrArr+=' '}
    if ($RemoveCharFromString_IsSymbol_BackQuote) {$RemoveStrArr+='`'}
    if ($RemoveCharFromString_IsSymbol_Tilde) {$RemoveStrArr+='~'}
    if ($RemoveCharFromString_IsSymbol_Exclamation) {$RemoveStrArr+='!'}
    if ($RemoveCharFromString_IsSymbol_AtOrAmpersat) {$RemoveStrArr+='@'}
    if ($RemoveCharFromString_IsSymbol_PoundOrHash) {$RemoveStrArr+='#'} 
    if ($RemoveCharFromString_IsSymbol_USD) {$RemoveStrArr+='$'}
    if ($RemoveCharFromString_IsSymbol_Percent) {$RemoveStrArr+='%'}
    if ($RemoveCharFromString_IsSymbol_Caret) {$RemoveStrArr+='^'}  
    if ($RemoveCharFromString_IsSymbol_Ampersand) {$RemoveStrArr+='&'}
    if ($RemoveCharFromString_IsSymbol_Asterisk) {$RemoveStrArr+='*'}
    if ($RemoveCharFromString_IsSymbol_OpenParen) {$RemoveStrArr+='('}
    if ($RemoveCharFromString_IsSymbol_CloseParen) {$RemoveStrArr+=')'}
    if ($RemoveCharFromString_IsSymbol_Hyphen) {$RemoveStrArr+='-'}
    if ($RemoveCharFromString_IsSymbol_Underscore) {$RemoveStrArr+='_'}
    if ($RemoveCharFromString_IsSymbol_Equal) {$RemoveStrArr+='='}
    if ($RemoveCharFromString_IsSymbol_Plus) {$RemoveStrArr+='+'}
    if ($RemoveCharFromString_IsSymbol_OpenBracket) {$RemoveStrArr+='['}
    if ($RemoveCharFromString_IsSymbol_CloseBracket) {$RemoveStrArr+=']'}
    if ($RemoveCharFromString_IsSymbol_OpenBrace) {$RemoveStrArr+='{'}
    if ($RemoveCharFromString_IsSymbol_CloseBrace) {$RemoveStrArr+='}'}
    if ($RemoveCharFromString_IsSymbol_Comma) {$RemoveStrArr+=','}
    if ($RemoveCharFromString_IsSymbol_Period) {$RemoveStrArr+='.'}
    if ($RemoveCharFromString_IsSymbol_VerticalBarOrPipe) {$RemoveStrArr+='|'}        
    if ($RemoveCharFromString_IsSymbol_BackSlash) {$RemoveStrArr+='\'}
    if ($RemoveCharFromString_IsSymbol_ForwardSlash) {$RemoveStrArr+='/'}
    if ($RemoveCharFromString_IsSymbol_SingleQuote) {$RemoveStrArr+="'"}
    if ($RemoveCharFromString_IsSymbol_DoubleQuote) {$RemoveStrArr+='"'}
    if ($RemoveCharFromString_IsSymbol_Colon) {$RemoveStrArr+=':'}
    if ($RemoveCharFromString_IsSymbol_SemiColon) {$RemoveStrArr+=';'}
    if ($RemoveCharFromString_IsSymbol_LessThanAngleBracket) {$RemoveStrArr+='<'}
    if ($RemoveCharFromString_IsSymbol_GreaterThanAngleBracket) {$RemoveStrArr+='>'}
    if ($RemoveCharFromString_IsSymbol_Question) {$RemoveStrArr+='?'}

    #endregion Assign Delimiter and Qualifier parameter booleans to respective arrays

    #region Remove content from input string
    #region Local Variables for removing content from input string
    $inParamNm=$false
    $inParamVal=$false

    $inLitQual=$false
    $currLitQualStart=$null
    $currLitQualEnd=$null

    $continueOuterLoop=$false

    $nextCharIsLiteral=$false
    $nextCharIsLiteralLen="$literalEscStr".Length
    $currParamStartDelim=$null
    $currParamEndDelim=$null

    $currParamName=$null

    [int32]$indexPosition=0
    #endregion Local Variables for removing content from input string

    if ($null -ne $removeStrs)
    {
        # If user entered characters from boolean parameters, they are already populated in [string[]]$RemoveStrArr
        [string]$newInputString=$null
        [bool]$skipChar=$null
        
        $precedingChar=$null
        $counter=0
        $inLitQual=$false
        [char]$delim=$removeStrs_InputDelimChar
        # Add strings to remove from input string specified in [string]$removeStrs
        foreach ($i in "$removeStrs".ToCharArray())
        {
            # User can start-end $removeStrs with double quotes for literal string. If so, double quotes and $delim must be escaped
            if ($i -eq '"' -and $counter -eq 0) {$inLitQual=$true; $precedingChar=$i; continue}
            if ($i -eq '"' -and $counter -eq "$removeStrs".Length) {$inLitQual=$false; $precedingChar=$i; continue}
            if ($counter -eq 0 -and !$inLitQual) {$remStrArr+=$i; $precedingChar=$i; continue}

            if ($i -eq ' ' -and $inLitQual) {$remStrArr+=$i}
            elseif ($i -eq ' ' -and $precedingChar -eq ',') {$remStrArr+=$i}
            elseif ($i -eq '"' -and $inLitQual) {$remStrArr+=$i}
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
    #endregion Remove content from input string

    # Evaluate user strings for user indicated delimiters and text qualifiers.
    # DO STUFF




    for ($i=0; $i -le "$input".Length)
    {
        # Literal escape is useful (1) when inside text qualified string to escape a delimiter that would terminate the text qualified literal string or (2) when outside a text qualified string where you want to escape a delimiter that would trigger special meaning (e.g. start of parameter or start of qualified text). The next char will be literally interpreted.
        if (($inParamNm -and $ignLitEscStrIfInParamNm) `
            -or ($inParamVal -and $ignLitEscStrIfInParamVal) `
            -or ($inLitQual -and $ignLitEscStrIfInLitQualStr))
        {
            $nextCharIsLiteral=$false
        }
        elseif (!$nextCharIsLiteral -and ("$literalEscStr" -eq "$input".Substring($i,$nextCharIsLiteralLen)))
        {
            $nextCharIsLiteral=$true
            $nextCharIsSpecial=$false
            # If inside TextQualifer AND LiteralStringEscape is triggered, if char following LitStrEsc is not a special character, treat LitStrEsc as literal characters and not an escape string
            if ($ignEscStrIfNxtCharNotSpec -and $inLitQual -and !$LitQualsStartEndMustMatch)
            {
                foreach ($j in $LitQualsStartArr)
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
            elseif ($ignEscStrIfNxtCharNotSpec -and $inLitQual -and $LitQualsStartEndMustMatch)
            {
                if ("$currLitQualEnd".Length -eq 1 -and ("$currLitQualEnd" -eq "$input".ToCharArray()[$i+$nextCharIsLiteralLen]))
                {
                    $nextCharIsSpecial=$true
                }
                elseif ("$currLitQualEnd".Length -gt 1 -and ("$currLitQualEnd" -eq "$input".Substring($i+$nextCharIsLiteralLen,"$currLitQualEnd".Length)))
                {
                    $nextCharIsSpecial=$true
                }  
            }            
            # If inside ParameterName and Not InLitQualifer AND LiteralStringEscape is triggered, if char following LitStrEsc is not a special character, treat LitStrEsc as literal characters and not an escape string
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
        if (!$inLitQual -and !$nextCharIsLiteral)
        {
            $continueOuterLoop=$false
            foreach ($j in $LitQualsStartArr)
            {
                if ($j.Length -eq 1 -and $j -eq "$input".Substring($i,1))
                {
                    $inLitQual=$true
                    if ($LitQualsStartEndMustMatch) {$currLitQualEnd="$currLitQualStart"}
                    $i++
                    $continueOuterLoop=$true
                    break
                }
                elseif ("$j".Length -gt 1 -and $j -eq ("$input".substring($i,"$j".Length)))
                {
                    $inLitQual=$true
                    if ($LitQualsStartEndMustMatch) {$currLitQualEnd="$currLitQualStart"}
                    $i=$i+"$j".Length
                    $continueOuterLoop=$true
                    break
                }
            }

            if ($continueOuterLoop) {continue}
        } 

        #region End Text Qualifier
        # Evaluate current position of $input to determine if end of literal string created by $inLitQual. if $nextCharIsLiteral is true, it  
        if ($inLitQual -and !$nextCharIsLiteral -and $LitQualsStartEndMustMatch)
        {
            if ("$currLitQualEnd".Length -eq 1 -and ("$currLitQualEnd" -eq "$input".ToCharArray()[$i]))
            {
                $inLitQual=$false
                $i++
                continue
            }
            elseif ("$currLitQualEnd".Length -gt 1 -and ("$currLitQualEnd" -eq "$input".Substring($i,"$currLitQualEnd".Length)))
            {
                $inLitQual=$false
                $i=$i+"$currLitQualEnd".Length
                continue
            }        
        }
        elseif ($inLitQual -and !$nextCharIsLiteral -and !$LitQualsStartEndMustMatch)
        {
            $continueOuterLoop=$false
            foreach ($j in $LitQualsEndArr)
            {
                if ($j.Length -eq 1 -and $j -eq "$input".Substring($i,1))
                {
                    $inLitQual=$false
                    $currLitQualEnd=$null
                    $currLitQualStart=$null
                    $i++
                    $continueOuterLoop=$true
                    break
                }
                elseif ("$j".Length -gt 1 -and $j -eq ("$input".substring($i,"$j".Length)))
                {
                    $inLitQual=$false
                    $currLitQualEnd=$null
                    $currLitQualStart=$null
                    $i=$i+"$j".Length
                    $continueOuterLoop=$true
                    break
                }
            }

            if ($continueOuterLoop) {continue}
        }
        #endregion End Text Qualifier

        # After $inLitQual blocks are evaluated, $nextCharIsLiteral will no longer affect $inLitQual until next loop. As such, the rest of the logic in the outer loop will treat $inLitQual and $nextCharAsLiteral as the same. That is, the next charcter will be viewed as a literal. So, to simplify, $nextCharIsLiteral will be used to represent both. However, when the remainder of the loop is finsihed and ready to move on, $nextCharIsLiteral will need to be made $false so that it can be re-evaluated at the start of the loop.
        if ($inLitQual) {$nextCharIsLiteral=$true}

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