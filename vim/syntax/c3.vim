if exists("b:current_syntax")
	finish
endif

syntax match c3Operator "\v\.\.\.?"
syntax match c3Operator "\v(\<\<|\>\>|[<>=!+*/%&^|-])\=?"
syntax match c3Operator "\v\+\+|--|\&\&|\|\||\?\?|::|\?:|\=>|[(\[]<|>[)\]]|\$\$"
syntax match c3Operator "\v\{\|?|\|?\}|[;,:()\[\].~?]"

syntax match c3Identifier "\v<_*[a-z][A-Za-z0-9_]*>"

syntax match c3Constant "\v<_*[A-Z][A-Z0-9_]*>"

syntax match c3Label "\v<_*[A-Z][A-Z0-9_]*:"

syntax match c3Type "\v<_*[A-Z]_*[a-z][A-Za-z0-9_]*>"

syntax match c3PreProc "\v\$_*[a-z][A-Za-z0-9_]*>"
syntax match c3PreProc "\v\$_*[A-Z][A-Z0-9_]*>"
syntax match c3PreProc "\v\$_*[A-Z]_*[a-z][A-Za-z0-9_]*>"

syntax match c3Macro "\v[\@#]_*[a-z][A-Za-z0-9_]*>"
syntax match c3Macro "\v[\@#]_*[A-Z][A-Z0-9_]*>"
syntax match c3Macro "\v[\@#]_*[A-Z]_*[a-z][A-Za-z0-9_]*>"

syntax match c3Include "\v(^\s*import\s+)@<=_*[a-z][a-z0-9_]*(::_*[a-z][a-z0-9_]*)+>"

syntax match c3Number "\v<0[Xx][0-9A-Fa-f](_*[0-9A-Fa-f])*>"
syntax match c3Number "\v<0[Oo][0-7](_*[0-7])*>"
syntax match c3Number "\v<0[Bb][01](_*[01])*>"
syntax match c3Number "\v<[0-9](_*[0-9])*([iu](8|16|32|64|128)|([Uu][Ll]?|[Ll]))?>"

syntax match c3Float "\v<[0-9](_*[0-9])*[Ee][+-]?[0-9]+(f(8|16|32|64|128))?>"
syntax match c3Float "\v<0[Xx][0-9A-Fa-f](_*[0-9A-Fa-f])*[Pp][+-]?[0-9]+(f(8|16|32|64|128))?>"
syntax match c3Float "\v<[0-9](_*[0-9])*\.[0-9](_*[0-9])*([Ee][+-]?[0-9]+)?(f(8|16|32|64|128))?>"
syntax match c3Float "\v<0[Xx][0-9A-Fa-f](_*[0-9A-Fa-f])*\.[0-9A-Fa-f](_*[0-9A-Fa-f])*([Pp][+-]?[0-9]+)?(f(8|16|32|64|128))?>"

syntax match c3HexBytes "\v<x'([ \f\n\t\v]?[0-9A-Fa-f][ \f\n\t\v0-9A-Fa-f]+)+'"
syntax match c3HexBytes "\v<x\"([ \f\n\t\v]?[0-9A-Fa-f][ \f\n\t\v0-9A-Fa-f]+)+\""
syntax match c3HexBytes "\v<x`([ \f\n\t\v]?[0-9A-Fa-f][ \f\n\t\v0-9A-Fa-f]+)+`"

syntax match c3Base64 "\v<b64'([ \f\n\t\v]?[A-Za-z0-9+/][ \f\n\t\vA-Za-z0-9+/]+)+(\=|\=\=)?'"
syntax match c3Base64 "\v<b64\"([ \f\n\t\v]?[A-Za-z0-9+/][ \f\n\t\vA-Za-z0-9+/]+)+(\=|\=\=)?\""
syntax match c3Base64 "\v<b64`([ \f\n\t\v]?[A-Za-z0-9+/][ \f\n\t\vA-Za-z0-9+/]+)+(\=|\=\=)?`"

syntax match c3String "\v\"(\\.|[^\\\"])*\""
syntax match c3String "\v`(``|.)*`"

syntax match c3Character "\v'(\\.|[^\\'])*'"

syntax keyword c3Keyword
	\ any anyfault asm assert break const continue defer distinct extern
	\ fault finalize import initialize inline macro module nextcase null protocol
	\ return static tlocal typeid var void

syntax keyword c3Boolean false true

syntax keyword c3Conditional case default else if switch

syntax keyword c3Exception try catch

syntax keyword c3Function fn

syntax keyword c3Repeat do for foreach foreach_r while

syntax keyword c3StorageClass bitstruct enum struct union

syntax keyword c3Type
	\ bfloat16 bool char double float float16 float128 ichar int in128 iptr isz
	\ long short uint uint128 ulong uptr ushort usz

syntax keyword c3Typedef def

syntax match c3Attribute "\v\@align>"
syntax match c3Attribute "\v\@benchmark>"
syntax match c3Attribute "\v\@bigendian>"
syntax match c3Attribute "\v\@builtin>"
syntax match c3Attribute "\v\@callc>"
syntax match c3Attribute "\v\@deprecated>"
syntax match c3Attribute "\v\@export>"
syntax match c3Attribute "\v\@extern>"
syntax match c3Attribute "\v\@finalizer>"
syntax match c3Attribute "\v\@if>"
syntax match c3Attribute "\v\@init>"
syntax match c3Attribute "\v\@inline>"
syntax match c3Attribute "\v\@littleendian>"
syntax match c3Attribute "\v\@local>"
syntax match c3Attribute "\v\@maydiscard>"
syntax match c3Attribute "\v\@naked>"
syntax match c3Attribute "\v\@nodiscard>"
syntax match c3Attribute "\v\@noinit>"
syntax match c3Attribute "\v\@noinline>"
syntax match c3Attribute "\v\@noreturn>"
syntax match c3Attribute "\v\@nostrip>"
syntax match c3Attribute "\v\@obfuscate>"
syntax match c3Attribute "\v\@operator>"
syntax match c3Attribute "\v\@overlap>"
syntax match c3Attribute "\v\@packed>"
syntax match c3Attribute "\v\@private>"
syntax match c3Attribute "\v\@pure>"
syntax match c3Attribute "\v\@reflect>"
syntax match c3Attribute "\v\@section>"
syntax match c3Attribute "\v\@test>"
syntax match c3Attribute "\v\@unused>"
syntax match c3Attribute "\v\@used>"
syntax match c3Attribute "\v\@weak>"

syntax region c3Comment start="\v/\*"   end="\v\*/" contains=c3Comment,c3Todo
syntax region c3Comment start="\v//"    end="\v$"   contains=c3Todo
syntax region c3Comment start="\v/\*\*" end="\v\*/" contains=c3Contract,c3Todo

syntax match c3Contract "\v<\@require>"                   contained
syntax match c3Contract "\v<\@ensure>"                    contained
syntax match c3Contract "\v<\@param\s+\[(in|out|inout)\]" contained
syntax match c3Contract "\v<\@pure>"                      contained

syntax keyword c3Todo todo Todo TODO contained

highlight default link c3Attribute   Tag
highlight default link c3Base64      Constant
highlight default link c3Boolean     Boolean
highlight default link c3Character   Character
highlight default link c3Comment     Comment
highlight default link c3Conditional Conditional
highlight default link c3Constant    Constant
highlight default link c3Contract    SpecialComment
highlight default link c3Exception   Exception
highlight default link c3Float       Float
highlight default link c3Function    Function
highlight default link c3HexBytes    Constant
highlight default link c3Identifier  Identifier
highlight default link c3Include     Include
highlight default link c3Keyword     Keyword
highlight default link c3Label       Label
highlight default link c3Macro       Macro
highlight default link c3Number      Number
highlight default link c3Operator    Operator
highlight default link c3PreProc     PreProc
highlight default link c3Repeat      Repeat
highlight default link c3String      String
highlight default link c3Todo        c3Todo
highlight default link c3Type        Type
highlight default link c3Typedef     Typedef

let b:current_syntax = "c3"
