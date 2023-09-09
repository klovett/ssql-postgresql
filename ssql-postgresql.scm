
;-s ../..//Workspace ssql-postgresql

(include-relative "foops")

(module ssql-postgresql

(*postgresql-translator*)

(import scheme utf8)
(import (chicken base))
(import (only (chicken format) format))
(import (only (chicken string) string-intersperse))
(import ssql)
(import (only postgresql connection? escape-string))
(import foops)

(define *postgresql-translator*
  (let ((type->sql-converters
         `((,boolean? . boolean->sql)
           ,@(*ansi-translator* 'type->sql-converters)))
        (clauses-order (append (*ansi-translator* 'clauses-order)
                               '(returning))))

    (derive-object (*ansi-translator* self)
                   ((escape-string string)
                    (escape-string (ssql-connection) string))

                   ((boolean->sql boolean)
                    (if boolean "'t'" "'f'"))

                   ((clauses-order) clauses-order)

                   ((type->sql-converters) type->sql-converters)

                   ((array (elements ...))
                    (format #f "ARRAY[~A]"
                               (string-intersperse
                                (map (lambda (el)
                                       (self 'ssql->sql el))
                                     elements)
                                ", "))))))

(define-operators *postgresql-translator*
  (limit prefix)
  (offset prefix)
  (returning prefix "RETURNING" ", ")
  (random function)
  (@> infix)
  (<@ infix))

(register-sql-engine! connection? *postgresql-translator*)

)
