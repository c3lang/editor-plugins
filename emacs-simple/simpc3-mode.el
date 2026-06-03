(require 'subr-x)

(defvar simpc3-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; C/C++ style comments
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?* ". 23" table)
    (modify-syntax-entry ?\n "> b" table)
    ;; Chars are the same as strings
    (modify-syntax-entry ?' "\"" table)
    ;; Treat <> as punctuation (needed to highlight C++ keywords
    ;; properly in template syntax)
    (modify-syntax-entry ?< "." table)
    (modify-syntax-entry ?> "." table)
    (modify-syntax-entry ?& "." table)
    (modify-syntax-entry ?% "." table)
    table))

(defun simpc3-types ()
  '("void" "bool"
    "ichar" "char"
    ;; Integer types
    "short" "ushort" "int" "uint" "long" "ulong" "int128" "uint128"
    "iptr" "uptr"
    "sz" "usz"
    ;; Floating point types
    "float16" "bfloat" "float" "double" "float128"
    ;; Other types
    "any" "fault" "typeid" "untypedlist"
    ;; C compatibility types
    "CChar" "CShort" "CUShort" "CInt" "CUInt" "CLong" "CULong" "CLongLong" "CULongLong" "CFloat" "CDouble" "CLongDouble"
    ;; CT types
    "$Typefrom" "$Typeof"
    ))

(defun simpc3-keywords ()
  '("alias"       "asm"         "assert"
    "attrdef"     "bitstruct"   "break"
    "case"        "catch"       "const"
    "constdef"    "continue"    "default"
    "defer"       "do"          "else"
    "enum"        "extern"      "false"
    "faultdef"    "for"         "foreach"
    "foreach_r"   "fn"          "tlocal"
    "if"          "inline"      "import"
    "interface"   "lengthof"    "macro"
    "module"      "nextcase"    "null"
    "return"      "static"      "struct"
    "switch"      "true"        "try"
    "typedef"     "union"       "var"
    "while"
    "$assert"     "$case"       "$default"
    "$defined"    "$echo"       "$else"
    "$embed"      "$endfor"     "$endforeach"
    "$endif"      "$endswitch"  "$eval"
    "$error"      "$exec"       "$expand"
    "$feature"    "$for"        "$foreach"
    "$if"         "$include"    "$reflect"
    "$stringify"  "$switch"     "$vaarg"
))


(defun simpc3-font-lock-keywords ()
  (list
   `("#.*include \\(\\(<\\|\"\\).*\\(>\\|\"\\)\\)" . (1 font-lock-string-face))
   `(,(regexp-opt (simpc3-keywords) 'symbols) . font-lock-keyword-face)
   `(,(regexp-opt (simpc3-types) 'symbols) . font-lock-type-face)))

(defun simpc3--space-prefix-len (line)
  (- (length line)
     (length (string-trim-left line))))

(defun simpc3--previous-non-empty-line ()
  (save-excursion
    (forward-line -1)
    (while (and (not (bobp))
                (string-empty-p
                 (string-trim-right
                  (thing-at-point 'line t))))
      (forward-line -1))
    (thing-at-point 'line t)))

(defun simpc3--desired-indentation ()
  (let ((cur-line (string-trim-right (thing-at-point 'line t)))
        (prev-line (string-trim-right (simpc3--previous-non-empty-line)))
        (indent-len 4))
    (cond
     ((and (string-suffix-p "{" prev-line)
           (string-prefix-p "}" (string-trim-left cur-line)))
      (simpc3--space-prefix-len prev-line))
     ((string-suffix-p "{" prev-line)
      (+ (simpc3--space-prefix-len prev-line) indent-len))
     ((string-prefix-p "}" (string-trim-left cur-line))
      (max (- (simpc3--space-prefix-len prev-line) indent-len) 0))
     (t (simpc3--space-prefix-len prev-line)))))

(defun simpc3-indent-line ()
  (interactive)
  (when (not (bobp))
    (let* ((current-indentation
            (simpc3--space-prefix-len (thing-at-point 'line t)))
           (desired-indentation
            (simpc3--desired-indentation))
           (n (max (- (current-column) current-indentation) 0)))
      (indent-line-to desired-indentation)
      (forward-char n))))

;;;###autoload
(define-derived-mode simpc3-mode prog-mode "Simple C3"
  "Simple major mode for C3."
  :syntax-table simpc3-mode-syntax-table
  (setq-local font-lock-defaults '(simpc3-font-lock-keywords))
  (setq-local indent-line-function 'simpc3-indent-line)
  (setq-local comment-start "// "))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.c3\\'" . simpc3-mode))
(add-to-list 'auto-mode-alist '("\\.c3i\\'" . simpc3-mode))

(provide 'simpc3-mode)
