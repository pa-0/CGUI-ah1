/*
Created by Frankie Bagnardi
Forum topic: http://www.autohotkey.com/forum/topic74340.html
Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
v0.5

Modified by R3gX - http://www.autohotkey.com/board/topic/69236-regex-class/page-2#entry582249
*/

class RegEx
{
	Needle := "."
	static EMAIL := "i)(?:\b|^)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}(?:\b|$)"
	static EMAIL2 := "[a-z0-9!#$%&'*+/=?^_``{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_``"
	. "{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|"
	. "net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b"

	__New(N) {
		If StrLen(N)
			this.Needle := N
	}

	; All matches are stored in a 2-dimentional object
	; The format is Matches[MatchNumber, Subpattern]
	; In many cases Subpattern is a number
	; When using a named Subpattern, e.g., (?P<SubpatternName>pattern),
	; the result will be stored in SubpatternName also
	Match(H, N="") {
		If !Strlen(N)
			N := this.Needle ; Set default
		Matches     := {}
		Subpatterns := this.GetSubpatterns(N)
		Pos := 1, Match_ := ""
		While ( Pos := RegExMatch(H, N, Match_, Pos+StrLen(Match_)) )
		{
			MatchIndex := A_Index
			for Index,Subpattern in Subpatterns
			{
				Match := Match_%Subpattern%
				Matches[MatchIndex, Index] := Match
				If not (Subpattern=Subpattern*1) ; Subpattern is alpha or alnum
					Matches[MatchIndex, Subpattern] := Match
			}
		}
		Matches.Count := MatchIndex
		return Matches
	}

	; MatchCall is a callout function
	; It calls function F each time your needle matches
	;	F can be a string like "MyFuncName", or an object reference,
	;	e.g., Class.MyFuncName
	;	Do not include the parenthesis and parameters. Use C.F not C.F(Param)
	; Each subpattern is sent as a parameter
	MatchCall(H, F, N="") {
		If !Strlen(N)
			N := this.Needle ; Set default
		If !IsFunc(F)
			return
		If !IsObject(F)
			F := Func(F) ; Make it an object
		Pos := 1, Match_ := "", Results := {}
		While ( Pos := RegExMatch(H, N, Match_, Pos+StrLen(Match_)) ) {
			Params := []
			For Key,Subpattern in this.GetSubpatterns(N)
				Params.Insert(Match_%Subpattern%)
			( R := F.(Params*) ) ? Results.Insert(R)
		}
		Return, Results
	}

	; This is essentially a one line RegExMatch, as apposed to a command
	; Subpattern refers to the numbered or named subpatern to be returned
	;	For example, 1 or NamedSubpattern
	;	Omit this parameter or use "" to return the entire match
	; To capture multiple matches use Match()
	MatchSimple(H, Subpattern="", N="") {
		If !Strlen(N)
			N := this.Needle ; Set default
		RegExMatch(H, N, Match_)
		return Match_%Subpattern%
	}

	; Returns true if any mach is found, false otherwise
	Test(H, N="") {
		If !Strlen(N)
			N := this.Needle ; Set default
		Return !!RegExMatch(H, N)
	}

	; For each match in haystack H with needle N the function F will be called
	; F must either be a function object or the plain text name of a function
	; In your function F the return value will be used as a replacement
	; The first argument is the entire match and the others are the subpatterns
	ReplaceCall(H, F, N="", Start=1) {
		If !Strlen(N)
			N := this.Needle ; Set default
		If !IsFunc(F)
			return
		If !IsObject(F)
			F := Func(F) ; Make it an object
		Pos := 1, Match_ := "", Results := {}
		While ( Pos := RegExMatch(H, N, Match_, Pos+StrLen(Match_)) ) {
			Params := []
			For Key,Subpattern in this.GetSubpatterns(N)
				Params.Insert(Match_%Subpattern%)
			R := F.(Params*)

			; Credit to majkinetor for the next two lines
			Result .= SubStr(H, Start, Pos-Start) . R ; R is the return value
			Start := Pos + StrLen(Match_)
		}
		Return Result . SubStr(H, Start)
	}

	; Return all subpatterns in the needle
	; Subpatterns and named subpatterns will be found
	; Results will be returned in an array
	GetSubpatterns(N="") {
		If !Strlen(N)
			N := this.Needle ; Set default
		Subpatterns := [] , Subpatterns[0] := ""
		Pos := 0 , Subpatterns_Needle := "\(\?P<(?P<Name>.+?)>.+?\)|\(.+?\)"
		While ( Pos:=RegExMatch(N, Subpatterns_Needle, Subpattern, Pos+1) )
		{
			If SubpatternName
				Subpatterns.Insert(SubpatternName)
			else
				Subpatterns.Insert(A_Index)
		}
		return Subpatterns
	}

	; Sanatize a part of a needle to be literal
	; This is most useful when receiving input from the user
	; The following characters are escaped:
	;	\.?*+[]{}()|^$
	Literal(N="") {
		If !Strlen(N)
			N := this.Needle ; Set default
		 return RegExReplace(N, "([\\\.\?\*\+\[\]\{\}\(\)\|\^\$])", "\$1")
	}

	; Add one or more options to the needle
	AddOptions(Options, N="")
	{
		static OptionsList := "imsxACDJOPSUX`r`n`a"
		If !Strlen(N)
			N := this.Needle ; Set default
		If not RegExMatch(Options, "[" OptionsList "]")
			Return, N
		Else If (StrLen(Options)>1)
		{
			Loop, Parse, Options
				N := this.AddOptions(A_LoopField, N)
			Return, N
		}
		OptionsRx := "^([" OptionsList "]+?\))?(.+)"
		RegExMatch(N, OptionsRx, M)
		NewN := (not M1) 			 ? Options ")" M2
				: InStr(M1, Options) ? N
				: Options . N
		Return, (this.Needle := NewN)
	}
}
