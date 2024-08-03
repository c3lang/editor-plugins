;; Keyword
[
  "assert"
  "asm"
  "catch"
  "defer"
  "try"
  "var"
] @keyword

[
  "$alignof"
  "$and"
  "$append"
  "$assert"
  "$assignable"
  "$case"
  "$concat"
  "$default"
  "$defined"
  "$echo"
  "$else"
  "$embed"
  "$endfor"
  "$endforeach"
  "$endif"
  "$endswitch"
  "$eval"
  "$evaltype"
  "$error"
  "$exec"
  "$extnameof"
  "$feature"
  "$for"
  "$foreach"
  "$if"
  "$include"
  "$is_const"
  "$nameof"
  "$offsetof"
  "$or"
  "$qnameof"
  "$sizeof"
  "$stringify"
  "$switch"
  "$typefrom"
  "$typeof"
  "$vacount"
  "$vatype"
  "$vaconst"
  "$varef"
  "$vaarg"
  "$vaexpr"
  "$vasplat"
] @keyword.directive

"fn" @keyword.function
"macro" @keyword.function
"return" @keyword.return
"import" @keyword.import
"module" @keyword.module

[
  "bitstruct"
  "def"
  "distinct"
  "enum"
  "fault"
  "interface"
  "struct"
  "union"
] @keyword.type

[
  "case"
  "default"
  "else"
  "if"
  "nextcase"
  "switch"
] @keyword.conditional

[
  "break"
  "continue"
  "do"
  "for"
  "foreach"
  "foreach_r"
  "while"
] @keyword.repeat

[
  "const"
  "extern"
  "inline"
  "static"
  "tlocal"
] @keyword.modifier

;; Punctuation
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

;; Operator
[
  "&"
  "!"
  "~"
  "|"
  "^"
  ;; ":"
  ;; ","
  ;; ";"
  "="
  ">"
  "/"
  "."
  ;; "#"
  "<"
  ;; "{"
  ;; "["
  ;; "("
  "-"
  "%"
  "+"
  "?"
  ;; "}"
  ;; "]"
  ;; ")"
  "*"
  ;; "_"
  "&&"
  ;; "->"
  "!!"
  "&="
  "|="
  "^="
  "/="
  ".."
  "?:"
  "=="
  ">="
  "=>"
  "<="
  ;; "{|"
  ;; "(<"
  ;; "[<"
  "-="
  "--"
  "%="
  "*="
  "!="
  "||"
  "+="
  "++"
  ;; "|}"
  ;; ">)"
  ;; ">]"
  "??"
  ;; "::"
  "<<"
  ">>"
  "..."
  "<<="
  ">>="
] @operator

[
  ";"
  ","
  ":"
  "::"
] @punctuation.delimiter

(range_expr ":" @operator)

(ternary_expr
  [
    "?"
    ":"
  ] @keyword.conditional.ternary)

(elvis_orelse_expr
  [
    "?:"
    "??"
  ] @keyword.conditional.ternary)

;; Literal
(integer_literal) @number
(real_literal) @number.float
(char_literal) @character
(bytes_literal) @number

;; String
(string_literal) @string
(raw_string_literal) @string

;; Escape Sequence
(escape_sequence) @string.escape

;; Builtin (constants)
((builtin) @constant.builtin (#match? @constant.builtin "_*[A-Z][_A-Z0-9]*"))

;; Type Property
(type_access_expr (access_ident [(ident) "typeid"] @variable.builtin
                                (#any-of? @variable.builtin
                                          "alignof"
                                          "associated"
                                          "elements"
                                          "extnameof"
                                          "inf"
                                          "is_eq"
                                          "is_ordered"
                                          "is_substruct"
                                          "len"
                                          "max"
                                          "membersof"
                                          "min"
                                          "nan"
                                          "inner"
                                          "kindof"
                                          "names"
                                          "nameof"
                                          "params"
                                          "parentof"
                                          "qnameof"
                                          "returns"
                                          "sizeof"
                                          "values"
                                          "typeid")))

;; Constant
((const_ident) @constant (#set! priority 1))
["true" "false"] @boolean
["null"] @constant.builtin

;; Label
[
  (label)
  (label_target)
] @label

;; Module
(module_resolution (ident) @module)
(module (path_ident (ident) @module))
(import_declaration (path_ident (ident) @module))

;; Attribute
(attribute name: (_) @attribute)
(define_attribute name: (_) @attribute)
(call_inline_attributes (at_ident) @attribute)

;; Type
[
  (type_ident)
  (ct_type_ident)
] @type
(base_type_name) @type.builtin

;; Function Definition
(func_header name: (_) @function)
(func_header method_type: (_) name: (_) @function.method)
;; NOTE macro_declaration can also have a func_header
(macro_header name: (_) @function)
(macro_header method_type: (_) name: (_) @function.method)

;; Variable
((ident) @variable (#set! priority 1))
((field_expr field: (access_ident (ident) @variable.member)) (#set! priority 2))
(struct_member_declaration (identifier_list (ident) @variable.member))
(bitstruct_member_declaration (ident) @variable.member)
;; (global_declaration (ident) @variable)
;; (multi_declaration (ident) @variable)
;; (local_decl_after_type name: (_) @variable)
;; (try_unwrap (ident) @variable)
(parameter [(ident) (ct_ident) (hash_ident)] @variable.parameter)
(call_invocation (arg (param_path) @variable.parameter))
(initializer_list (arg (param_path) @variable.member))

;; Function Call
(call_expr function: [(ident) (at_ident)] @function.call)
(call_expr function: [(builtin)] @function.builtin.call)
(call_expr function: (module_ident_expr ident: (_) @function.call))
(call_expr function: (trailing_generic_expr argument: (module_ident_expr ident: (_) @function.call)))
(call_expr function: (field_expr field: (_) @function.method.call)) ; Ambiguous, could be calling a method or function pointer
;; Method on type
(call_expr function: (type_access_expr field: (access_ident [(ident) (at_ident)] @function.method.call)))

;; Assignment
;; (assignment_expr left: (ident) @variable.member)
;; (assignment_expr left: (module_ident_expr (ident) @variable.member))
;; (assignment_expr left: (field_expr field: (_) @variable.member))
;; (assignment_expr left: (unary_expr operator: "*" @variable.member))
;; (assignment_expr left: (subscript_expr ["[" "]"] @variable.member))

;; (update_expr argument: (ident) @variable.member)
;; (update_expr argument: (module_ident_expr ident: (ident) @variable.member))
;; (update_expr argument: (field_expr field: (_) @variable.member))
;; (update_expr argument: (unary_expr operator: "*" @variable.member))
;; (update_expr argument: (subscript_expr ["[" "]"] @variable.member))

;; (unary_expr operator: ["--" "++"] argument: (ident) @variable.member)
;; (unary_expr operator: ["--" "++"] argument: (module_ident_expr (ident) @variable.member))
;; (unary_expr operator: ["--" "++"] argument: (field_expr field: (access_ident (ident)) @variable.member))
;; (unary_expr operator: ["--" "++"] argument: (subscript_expr ["[" "]"] @variable.member))

;; Comment
[
  (line_comment)
  (block_comment)
] @comment @spell

(doc_comment) @comment.documentation @spell
