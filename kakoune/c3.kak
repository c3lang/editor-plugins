hook global BufCreate .*[.]c3 %{
    set-option buffer filetype c3
}

addhl shared/c3                 regions
addhl shared/c3/code            default-region group
addhl shared/c3/comment-line    region '//' '$' fill comment
addhl shared/c3/comment-block   region /\*  \*/ fill comment
addhl shared/c3/double-string   region 'c?"' (?<!\\)(\\\\)*" fill string
addhl shared/c3/single-string   region "'" (?<!\\)(\\\\)*' fill string

addhl shared/c3/code/		    regex '\b(?:asm|assert|bitstruct|break|case|catch|const|continue)\b' 0:keyword
addhl shared/c3/code/		    regex '\b(?:def|default|defer|distinct|do|else|enum|extern)\b' 0:keyword
addhl shared/c3/code/		    regex '\b(?:false|fault|for|foreach|foreach_r|fn|tlocal|if)\b' 0:keyword
addhl shared/c3/code/		    regex '\b(?:inline|import|macro|module|nextcase|null|return|static)\b' 0:keyword
addhl shared/c3/code/		    regex '\b(?:struct|switch|true|try|union|var|while)\b' 0:keyword
addhl shared/c3/code/           regex '\b(?:%switch|$default|$case|$if|$typeof|$else|$sizeof|$for|$case)\b' 0:keyword

addhl shared/c3/code/builtin    regex '($)(\w+)' 1:default 2:function
addhl shared/c3/code/bool       regex '\b(?:true|false)\b' 0:keyword
addhl shared/c3/code/type       regex '\b(?:any|anyfault|bool|char|ichar|short|ushort|int|uint|long|ulong|int128|uint128|isz|usz|iptr|uptr|float16|float|double|float128|typeid|void)\b' 0:type
addhl shared/c3/code/operator   regex '(\.|>|<|=|\+|-|\*|/|%|&|^|\||!|:|\?|;|,|@)=?' 0:default
addhl shared/c3/code/num        regex '\b[0-9]+(.[0-9]+)=([eE][+-]?[0-9]+)=' 0:value

hook -group c3-highlight global WinSetOption filetype=c3 %{ add-highlighter window/ ref c3 }
hook -group c3-highlight global WinSetOption filetype=(?!c3).* %{ remove-highlighter window/c3 }
