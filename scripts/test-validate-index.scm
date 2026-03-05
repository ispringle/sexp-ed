#!/usr/bin/env guile
!#

;;; Test suite for validate-index.scm
;;; Run this with: ./scripts/test-validate-index.scm

(use-modules (ice-9 popen)
             (ice-9 rdelim)
             (ice-9 textual-ports)
             (srfi srfi-11))  ; for let-values

;; Test counter
(define tests-run 0)
(define tests-passed 0)

;; Color codes for output
(define green "\x1b[32m")
(define red "\x1b[31m")
(define yellow "\x1b[33m")
(define reset "\x1b[0m")

;; Helper to escape shell arguments to prevent command injection
(define (shell-quote arg)
  (string-append "'" (string-join (string-split arg #\') "'\\''") "'"))

;; Helper to run validator and capture exit code
;; Uses shell-quote to properly escape arguments and avoid command injection
(define (run-validator . args)
  (let* ((quoted-args (map shell-quote args))
         (cmd (string-join (cons "./scripts/validate-index.scm" quoted-args) " "))
         (full-cmd (string-append cmd " >/dev/null 2>&1"))
         (exit-code (status:exit-val (system full-cmd))))
    (values exit-code "")))

;; Test assertion helper
(define (assert-equal expected actual test-name)
  (set! tests-run (+ tests-run 1))
  (if (equal? expected actual)
      (begin
        (set! tests-passed (+ tests-passed 1))
        (format #t "~a✓~a ~a~%" green reset test-name))
      (format #t "~a✗~a ~a~%  Expected: ~a~%  Got: ~a~%"
              red reset test-name expected actual)))

;; Test: Valid file should return exit code 0
(define (test-valid-file)
  (let-values (((exit-code output) (run-validator "pages/index.scm")))
    (assert-equal 0 exit-code "Valid file should exit with 0")))

;; Test: No argument should use default path
(define (test-default-path)
  (let-values (((exit-code output) (run-validator)))
    (assert-equal 0 exit-code "Default path should work")))

;; Test: Non-existent file should return exit code 1
(define (test-nonexistent-file)
  (let-values (((exit-code output) (run-validator "nonexistent.scm")))
    (assert-equal 1 exit-code "Non-existent file should exit with 1")))

;; Test: Create a broken file with syntax error
(define (test-syntax-error)
  (let ((broken-file "/tmp/test-broken-syntax.scm"))
    ;; Create a file with syntax error
    (call-with-output-file broken-file
      (lambda (port)
        (display "(define x\n" port)))  ; Missing closing paren

    (let-values (((exit-code output) (run-validator broken-file)))
      (delete-file broken-file)
      (assert-equal 2 exit-code "Syntax error should exit with 2"))))

;; Test: Create a file with missing required functions
(define (test-missing-functions)
  (let ((incomplete-file "/tmp/test-incomplete.scm"))
    ;; Create a file that loads but is missing required functions
    ;; Uses the correct module name (pages index) that the validator checks for
    (call-with-output-file incomplete-file
      (lambda (port)
        (display "(define-module (pages index) #:export (index-content))\n" port)
        (display "(define (index-content) '(div \"test\"))\n" port)))

    (let-values (((exit-code output) (run-validator incomplete-file)))
      (delete-file incomplete-file)
      (assert-equal 3 exit-code "Missing functions should exit with 3"))))

;; Run all tests
(define (run-tests)
  (format #t "~%Running validation tests...~%~%")

  (test-valid-file)
  (test-default-path)
  (test-nonexistent-file)
  (test-syntax-error)
  (test-missing-functions)

  (format #t "~%~a~a/~a tests passed~a~%"
          (if (= tests-passed tests-run) green red)
          tests-passed
          tests-run
          reset)

  (if (= tests-passed tests-run) 0 1))

;; Main
(exit (run-tests))
