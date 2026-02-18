hook global BufCreate .*[.]c3[it]? %{
	set-option buffer filetype c3
}

hook -group c3-highlight global WinSetOption filetype=c3 %{
	require-module c3
	set-option window static_words %opt{c3_static_words}

	add-highlighter window/c3 ref c3
	hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/c3 }
}


provide-module c3 %{

addhl shared/c3                   regions
addhl shared/c3/code              default-region group

addhl shared/c3/comment-line      region '//' '$' fill comment
addhl shared/c3/comment-block     region -recurse '/\*' /\*  \*/ fill comment
addhl shared/c3/comment-doc       region <\*(?!>) \*> fill comment
addhl shared/c3/double-string     region '"' (?<!\\)(\\\\)*" fill string
addhl shared/c3/single-string     region "'" (?<!\\)(\\\\)*' fill string
addhl shared/c3/literal-string    region "`" (?<!\\)(\\\\)*` fill string
addhl shared/c3/code/shebang      regex '\A#! ?/.*?\n' 0:comment

addhl shared/c3/code/asterisk     regex '(?:\[<?)\s*(\*)\s*(?:>?\])' 1:value

addhl shared/c3/code/module-decl  regex '^\s*(module|import)\s+[a-z0-9_]+(?:::[a-z0-9_]+)*(?:(?:,\s*[a-z0-9_]+(?:::[a-z0-9_]+)*)+)?' 0:module
addhl shared/c3/code/num          regex '\b[+-]?(?:0(?:[xX][0-9a-fA-F](?:_*[0-9a-fA-F])*|[oO][0-7](?:_*[0-7])*|[bB][10](?:_*[10])*)|[0-9](?:_*[0-9])*(?:_*[eE][+-]?[0-9]+)?)(?:[iIuU](?:8|16|32|64|128)?|[fF](?:32|64)?|[uU][lL])?\b' 0:value
addhl shared/c3/code/const        regex '\$?\b_*[A-Z][A-Z_0-9]*\b' 0:value
addhl shared/c3/code/type         regex '\$?\b_*[A-Z][A-Z_0-9]*[a-z][A-Z_0-9a-z]*\b' 0:value
addhl shared/c3/code/user-attr    regex '@\b[A-Z][A-Z_0-9]*[a-z][A-Z_0-9a-z]*\b' 0:attribute
addhl shared/c3/code/func         regex '(?:[@#$])?\b_*[a-z][a-zA-Z0-9_]*\s*(?=\()' 0:function
addhl shared/c3/code/module       regex '([a-z0-9_]+)(?=::)' 1:module
addhl shared/c3/code/namespace    regex '::' 0:Default

evaluate-commands %sh{
	keywords='alias assert asm attrdef bitstruct break case catch cenum const continue default defer do else enum extern false faultdef for foreach foreach_r fn tlocal if inline import lengthof macro module nextcase null interface return static struct switch true try typedef union var while'
	attributes='align allow_deprecated benchmark bigendian builtin callconv cname compact const constinit deprecated dynamic export extern finalizer format if inline init jump link littleendian local maydiscard naked noalias nodiscard noinit noinline nopadding norecurse noreturn nosanitize nostrip obfuscate operator operator_r operator_s optional overlap packed private public pure reflect safeinfer safemacro simd section structlike tag test unused used wasm weak winmain'
	builtins='abs any_make atomic_load atomic_store atomic_fetch_exchange atomic_fetch_add atomic_fetch_sub atomic_fetch_and atomic_fetch_nand atomic_fetch_or atomic_fetch_xor atomic_fetch_max atomic_fetch_min atomic_fetch_inc_wrap atomic_fetch_dec_wrap bitreverse breakpoint bswap ceil compare_exchange copysign cos clz ctz add div mod mul neg sub exp exp2 expect expect_with_probability fence floor fma fmuladd frameaddress fshl fshr gather get_rounding_mode int_to_mask log log10 log2 matrix_mul matrix_transpose mask_to_int masked_load masked_store max memcpy memcpy_inline memmove memset memset_inline min nearbyint overflow_add overflow_mul overflow_sub popcount pow pow_int prefetch reduce_add reduce_and reduce_fadd reduce_fmul reduce_max reduce_min reduce_mul reduce_or reduce_xor reverse returnaddress rint rnd round roundeven sat_add sat_shl sat_sub sat_mul scatter select set_rounding_mode sprintf str_find str_hash str_lower str_pascalcase str_replace str_upper str_snakecase swizzle swizzle2 sin sqrt syscall sysclock trap trunc unaligned_load unaligned_store unreachable veccomplt veccomple veccompgt veccompge veccompeq veccompne volatile_load volatile_store wasm_memory_size wasm_memory_grow wstr16 wstr32 DATE FILE FILEPATH FUNC FUNCTION LINE LINE_RAW MODULE BENCHMARK_NAMES BENCHMARK_FNS TEST_NAMES TEST_FNS TIME BUILD_HASH BUILD_DATE OS_TYPE ARCH_TYPE MAX_VECTOR_SIZE REGISTER_SIZE COMPILER_LIBC_AVAILABLE CUSTOM_LIBC COMPILER_OPT_LEVEL PLATFORM_BIG_ENDIAN PLATFORM_I128_SUPPORTED PLATFORM_F16_SUPPORTED PLATFORM_F128_SUPPORTED REGISTER_SIZE COMPILER_SAFE_MODE DEBUG_SYMBOLS BACKTRACE LLVM_VERSION BENCHMARKING TESTING PANIC_MSG MEMORY_ENVIRONMENT ADDRESS_SANITIZER MEMORY_SANITIZER THREAD_SANITIZER LANGUAGE_DEV_VERSION AUTHORS AUTHOR_EMAILS PROJECT_VERSION'
	types='void bool char double float float16 bfloat int128 ichar int iptr isz long short uint128 uint ulong uptr ushort usz float128 any fault typeid'
	comptime_keywords='alignof assert assignable case default defined echo else embed endfor endforeach endif endswitch eval evaltype error exec extnameof feature for foreach if include is_const kindof nameof offsetof qnameof sizeof stringify switch typefrom typeof vacount vatype vaconst vaarg vaexpr vasplat'

	join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

	printf %s\\n "declare-option str-list c3_static_words $(echo ${keywords} ${attributes} ${types} ${builtins} ${comptime_keywords})'"

	printf %s "
	addhl shared/c3/code/keywords          regex '(?<![@#$])\b(?:$(join '${keywords}' '|'))\\b' 0:keyword
	addhl shared/c3/code/comptime-keywords regex '[$](?:$(join '${comptime_keywords}' '|'))\\b' 0:keyword
	addhl shared/c3/code/builtins          regex '[$]{2}(?:$(join '${builtins}' '|'))\\b' 0:keyword
	addhl shared/c3/code/attributes        regex '[@]\b(?:$(join '${attributes}' '|'))\\b' 0:attribute
	addhl shared/c3/code/types             regex '(?<![@#$])\\b(?:$(join '${types}' '|'))\\b' 0:type
	"
}

}
