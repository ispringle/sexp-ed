#!/usr/bin/env guile
!#

;;; Tests for add-resource.scm. Runs against the REAL pages/index.scm via a temp copy.
;;; Usage: ./scripts/test-add-resource.scm

(use-modules (ice-9 popen) (ice-9 textual-ports))

(define tmp "/tmp/sexp-ed-test-index.scm")
(define real "pages/index.scm")
(define failures 0)

(define (read-file f) (call-with-input-file f get-string-all))
(define (reset!) (call-with-output-file tmp (lambda (p) (display (read-file real) p))))

;; Run script with INDEX_FILE=tmp; returns exit status.
(define (run . args)
  (setenv "INDEX_FILE" tmp)
  (let ((s (status:exit-val (apply system* "scripts/add-resource.scm" "--in-place" args))))
    s))

(define (check name ok)
  (format #t "~a ~a~%" (if ok "✓" "✗") name)
  (unless ok (set! failures (+ failures 1))))

(define (count-lines text) (length (string-split text #\newline)))

(reset!)
(check "adds to scheme" (eqv? 0 (run "scheme" "T \"q\"" "https://x.org/" "d (x)" "[\"a\", \"b\"]")))
(let ((new (read-file tmp)) (old (read-file real)))
  (check "card present" (string-contains new "\"T \\\"q\\\"\""))
  (check "only 5 lines added" (= 5 (- (count-lines new) (count-lines old))))
  (check "comments kept" (string-contains new ";; Scheme section"))
  (check "other sections kept" (and (string-contains new "hero-section") (string-contains new "history-section")))
  (check "result parses" (catch #t (lambda () (call-with-input-string new (lambda (p) (let l () (or (eof-object? (read p)) (l)))))) (lambda _ #f))))

(reset!)
(check "empty grid (janet) ok" (eqv? 0 (run "janet" "J" "https://j.org" "d" "[]")))
(check "twice ok" (eqv? 0 (run "janet" "K" "https://k.org" "d" "[\"free\"]")))
(reset!)
(check "bad section -> 4" (eqv? 4 (run "nope" "T" "https://x.org" "d" "[]")))
(check "bad url -> 5" (eqv? 5 (run "scheme" "T" "javascript:alert(1)" "d" "[]")))
(check "bad tags -> 5" (eqv? 5 (run "scheme" "T" "https://x.org" "d" "[\"a b\"]")))
(check "empty title -> 5" (eqv? 5 (run "scheme" "" "https://x.org" "d" "[]")))
(check "too few args -> 1" (eqv? 1 (run "scheme")))
(check "failed runs leave file unchanged" (string=? (read-file tmp) (read-file real)))

(delete-file tmp)
(format #t "~a~%" (if (zero? failures) "ALL PASS" "FAILURES"))
(exit (if (zero? failures) 0 1))
