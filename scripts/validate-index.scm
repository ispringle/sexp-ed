#!/usr/bin/env guile
!#

;;; Validator for pages/index.scm
;;; Usage: ./scripts/validate-index.scm [path-to-index.scm]
;;;
;;; Exit codes:
;;;   0 - Valid file
;;;   1 - File not found
;;;   2 - Parse/syntax error
;;;   3 - Missing required functions

(use-modules (ice-9 format)
             (ice-9 exceptions))

;; List of required functions
(define required-functions
  '(general-section
    common-lisp-section
    scheme-section
    racket-section
    clojure-section
    emacs-lisp-section
    janet-section
    others-section
    index-content))

;; Check if file exists
(define (file-exists? filepath)
  (access? filepath R_OK))

;; Try to load a file and catch any errors
(define (try-load-file filepath)
  (with-exception-handler
    (lambda (exn)
      (format (current-error-port) "Error loading file: ~a~%" exn)
      #f)
    (lambda ()
      (primitive-load filepath)
      #t)
    #:unwind? #t))

;; Check if a symbol is bound to a procedure in a module
(define (function-exists? module-name func-name)
  (catch #t
    (lambda ()
      (let* ((mod (resolve-module module-name))
             (var (module-variable mod func-name)))
        (and var
             (variable-bound? var)
             (procedure? (variable-ref var)))))
    (lambda (key . args)
      #f)))

;; Check if all required functions exist in the module
(define (check-required-functions module-name)
  (let ((missing (filter (lambda (func)
                           (not (function-exists? module-name func)))
                         required-functions)))
    (if (null? missing)
        #t
        (begin
          (format (current-error-port) "Missing required functions:~%")
          (for-each (lambda (func)
                      (format (current-error-port) "  - ~a~%" func))
                    missing)
          #f))))

;; Main validation function
(define (validate-index-file filepath)
  (cond
   ;; Check if file exists
   ((not (file-exists? filepath))
    (format (current-error-port) "Error: File not found: ~a~%" filepath)
    (exit 1))

   ;; Try to load the file
   ((not (try-load-file filepath))
    (format (current-error-port) "Error: Failed to load file (syntax error)~%")
    (exit 2))

   ;; Check if all required functions exist
   ;; NOTE: The module name '(pages index) is hardcoded because this validator
   ;; is specifically designed for pages/index.scm in the sexp-ed project.
   ;; If validating a different file with a different module name, this check
   ;; will need to be updated accordingly.
   ((not (check-required-functions '(pages index)))
    (format (current-error-port) "Error: Missing required functions~%")
    (exit 3))

   ;; All checks passed
   (else
    (format #t "✓ File is valid~%")
    (exit 0))))

;; Entry point
(define (main args)
  (let ((filepath (if (> (length args) 1)
                      (cadr args)
                      "pages/index.scm")))
    (validate-index-file filepath)))

;; Run main
(main (command-line))
