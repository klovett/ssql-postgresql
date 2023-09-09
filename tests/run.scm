
;-s ../..//Workspace ssql-postgresql

(include-relative "../foops")

(import test)

(import (only (chicken string) string-translate*))

(import ssql)
(import ssql-postgresql)
(import foops)

(define *test-postgresql-translator*
  (derive-object (*postgresql-translator* self super)
                 ((escape-string string)
                  (string-translate* string '(("'" . "''"))))))

(register-sql-engine! (lambda (x) (eq? x #t)) *test-postgresql-translator*)

(test-group "selects"
  (test "Simple query"
    "SELECT actors.firstname, actors.lastname FROM actors"
    (ssql->sql #t `(select (columns actors.firstname actors.lastname)
                     (from actors)))))

(test-group "dialect"
  (test "LIMIT and OFFSET"
    "SELECT * FROM integers LIMIT 10 OFFSET 100"
    (ssql->sql #t `(select (columns *) (from integers) (limit 10) (offset 100))))

  (test "random()"
    "SELECT * FROM widgets ORDER BY RANDOM()"
    (ssql->sql #t `(select (columns *) (from widgets) (order (random)))))

  (test "returning"
    "INSERT INTO widgets VALUES ('foo', 'bar') RETURNING id, name"
    (ssql->sql #t '(insert (into widgets) (values #("foo" "bar")) (returning id name))))

  (test "compose returning"
    '(insert (into widgets) (values #(1 2 3)) (returning id))
    (ssql-compose #t '(insert (into widgets) (values #(1 2 3))) '((returning id)))))


(test-group "arrays"
  (test "literals"
    "SELECT ARRAY[1, 2, 3]"
    (ssql->sql #t '(select (array 1 2 3))))

  (test "contains operator"
    "SELECT (ARRAY['foo', 'bar'] @> ARRAY['bar'])"
    (ssql->sql #t '(select (@> (array "foo" "bar") (array "bar")))))

  (test "is contained operator"
    "SELECT (ARRAY['bar'] <@ ARRAY['foo', 'bar'])"
    (ssql->sql #t '(select (<@ (array "bar") (array "foo" "bar"))))))

(test-exit)