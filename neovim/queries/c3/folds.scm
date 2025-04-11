(func_definition) @fold    ; fold full fn declaration
;(func_definition (macro_func_body) @fold)  ; folds only {}, if on new line!

;(macro_declaration (macro_func_body)  @fold) ; folds only {}, if on new line!
(macro_declaration)  @fold

(switch_body ((case_stmt) @fold))
(enum_body) @fold
;(doc_comment_text)  @fold
