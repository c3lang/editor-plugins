hook global BufCreate .*[.]c3i? %{
    set-option buffer filetype c3
}

hook -group c3-highlight global WinSetOption filetype=c3 %{
#    require-module c3

    add-highlighter window/c3 ref c3
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/c3 }
}


# provide-module c3 %{

addhl shared/c3                   regions
addhl shared/c3/global            default-region regions
addhl shared/c3/global/code       default-region group
# addhl shared/c3/local/code        region -recurse '\{' '^\s*(?:fn|macro)[^)]+?\)[^;]*\{' '\}' regions
addhl shared/c3/local             region -recurse '\{' '\{' '\}' regions
addhl shared/c3/local/code        default-region group

# TODO: this does not work with 'fn void test() => {|<multiple lines>|};'
addhl shared/c3/lambda            region '=>' ';' regions
addhl shared/c3/lambda/code       default-region group

addhl shared/c3/comment-line      region '//' '$' fill comment
addhl shared/c3/comment-block     region -recurse '/\*' /\*  \*/ fill comment
addhl shared/c3/comment-doc       region <\* \*> fill comment
addhl shared/c3/double-string     region 'c?"' (?<!\\)(\\\\)*" fill string
addhl shared/c3/single-string     region "'" (?<!\\)(\\\\)*' fill string
addhl shared/c3/compiler-builtin  region '\$\$\w' '\b' fill keyword

# The order that the highlighters are defined is VERY important as the last one defined has priority
evaluate-commands %sh{
    keywords='
	asm assert bitstruct break case catch const continue
	def default defer distinct do else enum extern
	false fault for foreach foreach_r fn tlocal if
	inline import macro module nextcase null return static
	struct switch true try union var while
    '

    builtins='
	switch default case if typeof else sizeof for
	case foreach endif endfor endforeach endswitch
	alignof append assert assignable defined echo
	embed error eval evaltype exec extnameof qnameof
	nameof feature is_const nameof offsetof qnameof
	vacount vaconst vaexpr varef vasplat vatype
	sizeof stringify typeof typefrom
    '

    types='
	any anyfault bool char ichar short ushort int
	uint long ulong int128 uint128 isz usz iptr
	uptr float16 float double float128 typeid void
    '

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    all="local global lambda"
    for region in ${all}; do
	printf %s "
	addhl shared/c3/${region}/code/keyword  regex '\\b(?:$(join "${keywords}" '|'))\\b' 0:keyword
	addhl shared/c3/${region}/code/builtin  regex '[$]\\b(?:$(join "${builtins}" '|'))\\b' 0:keyword
	addhl shared/c3/${region}/code/bool       regex '\\b(?:true|false)\\b' 0:keyword
	addhl shared/c3/${region}/code/type       regex '\\b(?:$(join "${types}" '|'))\\b' 0:type
	addhl shared/c3/${region}/code/operator   regex '(?:\\.|>|<|=|\\+|-|\\*|/|%|&|\\^|\\||!|:|\\?|;|,|@)=?' 0:default
	addhl shared/c3/${region}/code/num        regex '(?<=[^A-Za-z0-9])[+-]?(?:0(?:[xX][0-9a-fA-F](?:_|[0-9a-fA-F])*|[oO][0-7](?:_|[0-7])*|[bB][10](?:_|[10])*)|[0-9](?:_?[0-9])*(?:_?[eE][+-]?[0-9]+)?)(?:i8|i16|i32|i64|i128|u8|u16|u32|u|u64|u128|f|f32|f64)?\b' 0:value
	addhl shared/c3/${region}/code/const-and-struct   regex '\\\$?\\b[A-Z]\\w*\\b' 0:value

	addhl shared/c3/${region}/comment-line      region '//' '$' fill comment
	addhl shared/c3/${region}/comment-block     region /\\*  \\*/ fill comment
	addhl shared/c3/${region}/comment-doc       region <\\* \\*> fill comment
	addhl shared/c3/${region}/double-string     region 'c?\"' (?<!\\\\)(\\\\\\\\)*\" fill string
	addhl shared/c3/${region}/single-string     region \"'\" (?<!\\\\)(\\\\\\\\)*' fill string
	addhl shared/c3/${region}/compiler-builtin  region '\\$\\$\\w' '\\b' fill keyword
	"
    done

    local="local lambda"
    for region in ${local}; do
	printf %s "
	addhl shared/c3/${region}/code/module  regex '\\b(\\w+)(?:::)' 1:module
	addhl shared/c3/${region}/code/function regex '[@#]?\\b(?![A-Z0-9])(?<!\\$)\\w+?(?=\\()' 0:function
	addhl shared/c3/${region}/code/attribute  regex '(?:\\w+\\s)(@\\w+)\\s*(?:(?=;)|(?==))' 1:attribute
	"
    done

    printf %s "
	addhl shared/c3/global/code/module-statement-start   regex '(?:module|import)\\s*(\\w+)' 1:module
	addhl shared/c3/global/code/module-statement-cont   regex '::(\\w*).*?(?:(?=::)|(?=;))' 1:module
	addhl shared/c3/global/code/function-statement   regex '(?:(?:fn|macro) +(?:[A-Za-z0-9_\\[\\]]*\\**!? +)?(?:[^ \\t]+\\.)?)(@?[a-z]\\w+(?=\\())' 1:function
	addhl shared/c3/global/code/attribute regex '[@][a-z]+' 0:attribute
    "
}

# }

