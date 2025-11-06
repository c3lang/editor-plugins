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

addhl shared/c3/code/module-decl  regex '(module|import)\s*[a-z0-9_]+(?:::[a-z0-9_]+)*(?:(?:,\s*[a-z0-9_]+(?:::[a-z0-9_]+)*)+|\s*(\{(?:\s*_*[A-Z][A-z0-9_]*,?\s*)+\}))?(?=;)' 0:module 1:Default 2:Default
addhl shared/c3/code/num          regex '\b[+-]?(?:0(?:[xX][0-9a-fA-F](?:_*[0-9a-fA-F])*|[oO][0-7](?:_*[0-7])*|[bB][10](?:_*[10])*)|[0-9](?:_*[0-9])*(?:_*[eE][+-]?[0-9]+)?)(?:[iIuU](?:8|16|32|64|128)?|[fF](?:32|64)?|[uU][lL])?\b' 0:value
addhl shared/c3/code/const        regex '\$?\b_*[A-Z][A-Z_0-9]*\b' 0:value
addhl shared/c3/code/type         regex '\$?\b_*[A-Z][A-Z_0-9]*[a-z][A-Z_0-9a-z]*\b' 0:value
addhl shared/c3/code/user-attr    regex '@\b[A-Z][A-Z_0-9]*[a-z][A-Z_0-9a-z]*\b' 0:attribute
addhl shared/c3/code/func         regex '(?:[@#$])?\b_*[a-z][a-zA-Z0-9_]*\s*(?=\()' 0:function
addhl shared/c3/code/module       regex '([a-z0-9_]+)(?=::)' 1:module
addhl shared/c3/code/namespace    regex '::' 0:Default

evaluate-commands %sh{
    keywords='alias assert asm attrdef bitstruct break case catch const continue default defer do else enum extern false faultdef for foreach foreach_r fn tlocal if inline import lengthof macro module nextcase null interface return static struct switch true try typedef union var while'
    attributes='align allow_deprecated benchmark bigendian builtin callconv compact const deprecated dynamic export extern finalizer format if inline init jump link littleendian local maydiscard naked noalias nodiscard noinit noinline nopadding norecurse noreturn nosanitize nostrip obfuscate operator operator_r operator_s optional overlap packed private public pure reflect safeinfer safemacro section structlike tag test unused used wasm weak winmain'
    builtins='abs add any_make atomic_fetch_add atomic_fetch_and atomic_fetch_dec_wrap atomic_fetch_exchange atomic_fetch_inc_wrap atomic_fetch_max atomic_fetch_min atomic_fetch_nand atomic_fetch_or atomic_fetch_sub atomic_fetch_xor atomic_load atomic_store bitreverse breakpoint bswap ceil clz compare_exchange copysign cos ctz div exp exp2 expect expect_with_probability fence floor fma fmuladd frameaddress fshl fshr gather get_rounding_mode log log10 log2 masked_load masked_store matrix_mul matrix_transpose max memcpy memcpy_inline memmove memset memset_inline min mod mul nearbyint neg overflow_add overflow_mul overflow_sub popcount pow pow_int prefetch reduce_add reduce_and reduce_fadd reduce_fmul reduce_max reduce_min reduce_mul reduce_or reduce_xor returnaddress reverse rint rnd round roundeven sat_add sat_mul sat_shl sat_sub scatter select set_rounding_mode sin sprintf sqrt str_find str_hash str_lower str_pascalcase str_replace str_snakecase str_upper sub swizzle swizzle2 syscall sysclock trap trunc unaligned_load unaligned_store unreachable veccompeq veccompge veccompgt veccomple veccomplt veccompne volatile_load volatile_store wasm_memory_grow wasm_memory_size wstr16 wstr32 BENCHMARK_FNS BENCHMARK_NAMES DATE FILE FILEPATH FUNC FUNCTION LINE LINE_RAW MODULE TEST_FNS TEST_NAMES TIME ADDRESS_SANITIZER ARCH_TYPE AUTHOR_EMAILS AUTHORS BACKTRACE BENCHMARKING BUILD_DATE BUILD_HASH COMPILER_LIBC_AVAILABLE COMPILER_OPT_LEVEL COMPILER_SAFE_MODE DEBUG_SYMBOLS LANGUAGE_DEV_VERSION LLVM_VERSION MAX_VECTOR_SIZE MEMORY_ENVIRONMENT MEMORY_SANITIZER OS_TYPE PANIC_MSG PLATFORM_BIG_ENDIAN PLATFORM_F128_SUPPORTED PLATFORM_F16_SUPPORTED PLATFORM_I128_SUPPORTED PROJECT_VERSION REGISTER_SIZE TESTING THREAD_SANITIZER'
    types='void bool char double float float16 bfloat int128 ichar int iptr isz long short uint128 uint ulong uptr ushort usz float128 any fault typeid'
    comptime_keywords='alignof assert assignable case default defined echo else embed endfor endforeach endif endswitch eval evaltype error exec extnameof feature for foreach if include is_const kindof nameof offsetof qnameof sizeof stringify switch typefrom typeof vacount vatype vaconst vaarg vaexpr vasplat'

    # Both joins with a separator and escapes '$' characters
    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*" | sed -e 's/\$/\\\$/g'; }

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
