;; 3) Declaration
; (declaration (identifier_list [(ident) (ct_ident)] @variable.declaration))
; (declaration name: [(ident) (ct_ident)] @variable.declaration)
; (var_declaration name: [(ident) (ct_ident)] @variable.declaration)
; (try_unwrap (ident) @variable.declaration)
; (catch_unwrap (ident) @variable.declaration)

; Assignment
; (assignment_expr left: (ident_expr (ident) @variable.member))
; (assignment_expr left: (field_expr field: (_) @variable.member))
; (assignment_expr left: (unary_expr operator: "*" @variable.member))
; (assignment_expr left: (subscript_expr ["[" "]"] @variable.member))
; (update_expr argument: (ident_expr ident: (ident) @variable.member))
; (update_expr argument: (field_expr field: (_) @variable.member))
; (update_expr argument: (unary_expr operator: "*" @variable.member))
; (update_expr argument: (subscript_expr ["[" "]"] @variable.member))
; (unary_expr operator: ["--" "++"] argument: (ident_expr (ident) @variable.member))
; (unary_expr operator: ["--" "++"] argument: (field_expr field: (access_ident (ident)) @variable.member))
; (unary_expr operator: ["--" "++"] argument: (subscript_expr ["[" "]"] @variable.member))
