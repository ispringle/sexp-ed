#!/usr/bin/env guile
!#

;;; Tests for add-resource.scm
;;; Usage: ./scripts/test-add-resource.scm

(use-modules (ice-9 format)
             (ice-9 exceptions)
             (ice-9 textual-ports)
             (ice-9 popen)
             (ice-9 ftw))

;; Test counter
(define test-count 0)
(define pass-count 0)

;; Test directory for isolation
(define test-dir "/tmp/sexp-ed-test")
(define test-pages-dir (string-append test-dir "/pages"))

;; Setup test environment
(define (setup-test-env)
  ;; Clean up any existing test directory
  (when (file-exists? test-dir)
    (system* "rm" "-rf" test-dir))
  ;; Create test directory structure
  (mkdir test-dir)
  (mkdir test-pages-dir))

;; Cleanup test environment
(define (cleanup-test-env)
  (when (file-exists? test-dir)
    (system* "rm" "-rf" test-dir)))

;; Test runner
(define (test name thunk)
  (set! test-count (+ test-count 1))
  (with-exception-handler
    (lambda (exn)
      (format #t "✗ ~a~%" name)
      (format #t "  Error: ~a~%" exn)
      #f)
    (lambda ()
      (if (thunk)
          (begin
            (set! pass-count (+ pass-count 1))
            (format #t "✓ ~a~%" name)
            #t)
          (begin
            (format #t "✗ ~a~%" name)
            #f)))
    #:unwind? #t))

;; Create a minimal test index.scm
(define test-index-content
  "(define-module (pages index)
  #:export (index-content))

(define (resource-card title url description tags)
  `(article (@ (class \"resource-card\"))
            (h4 (@ (class \"resource-title\"))
                (a (@ (href ,url)
                      (target \"_blank\")
                      (rel \"noopener noreferrer\"))
                   ,title))
            (p (@ (class \"resource-description\")) ,description)
            (div (@ (class \"resource-tags\"))
                 ,@(map (lambda (tag)
                          `(span (@ (class ,(string-append \"tag tag-\" tag))) ,tag))
                        tags))))

(define (scheme-section)
  `(section (@ (id \"scheme\") (class \"section dialect scheme\"))
            (h2 (@ (class \"section-title\"))
                (span (@ (class \"paren\")) \"(\")
                \"Scheme\"
                (span (@ (class \"paren\")) \")\"))
            (div (@ (class \"resources-grid\"))
                 ,(resource-card
                   \"Existing Resource\"
                   \"https://example.com\"
                   \"An existing resource\"
                   '(\"tag1\" \"tag2\")))))

(define (common-lisp-section)
  `(section (@ (id \"common-lisp\") (class \"section dialect cl\"))
            (h2 (@ (class \"section-title\"))
                (span (@ (class \"paren\")) \"(\")
                \"Common Lisp\"
                (span (@ (class \"paren\")) \")\"))
            (div (@ (class \"resources-grid\"))
                 ,(resource-card
                   \"CL Resource\"
                   \"https://example.com/cl\"
                   \"A Common Lisp resource\"
                   '(\"cl\")))))

(define (index-content)
  `(div (@ (class \"content\"))
        ,(scheme-section)
        ,(common-lisp-section)))
")

;; Helper to create test file
(define (create-test-file path content)
  (with-output-to-file path
    (lambda ()
      (display content))))

;; Helper to shell-quote an argument (handles newlines and control chars)
(define (shell-quote arg)
  (string-append "\""
                 (string-join
                  (map (lambda (char)
                         (cond
                          ((char=? char #\") "\\\"")
                          ((char=? char #\\) "\\\\")
                          ((char=? char #\$) "\\$")
                          ((char=? char #\`) "\\`")
                          ((char=? char #\newline) "\\n")
                          ((char=? char #\return) "\\r")
                          ((char=? char #\tab) "\\t")
                          ;; Filter out other control characters
                          ((char<? char #\space) "")
                          (else (string char))))
                       (string->list arg))
                  "")
                 "\""))

;; Helper to run script and capture output (runs in test directory)
(define (run-add-resource args)
  (let* ((script-path (string-append (getcwd) "/scripts/add-resource.scm"))
         (quoted-args (map shell-quote args))
         (cmd (string-append "cd " test-dir " && " (string-join (cons script-path quoted-args) " ") " 2>&1"))
         (output-port (open-input-pipe cmd))
         (output (get-string-all output-port))
         (status (close-pipe output-port)))
    (cons (status:exit-val status) output)))

;; Test 1: Script exists and is executable
(test "Script file exists and is executable"
      (lambda ()
        (and (access? "./scripts/add-resource.scm" R_OK)
             (access? "./scripts/add-resource.scm" X_OK))))

;; Test 2: Script shows usage when called with no arguments
(test "Script shows usage message with no arguments"
      (lambda ()
        (setup-test-env)
        (let ((result (run-add-resource '())))
          (cleanup-test-env)
          (and (not (= (car result) 0))
               (string-contains (cdr result) "Usage:")))))

;; Test 3: Script fails with invalid section
(test "Script fails with invalid section"
      (lambda ()
        (setup-test-env)
        (create-test-file (string-append test-pages-dir "/index.scm") test-index-content)
        (let ((result (run-add-resource
                       '("invalid-section"
                         "Test"
                         "https://test.com"
                         "Description"
                         "[\"tag\"]"))))
          (cleanup-test-env)
          (not (= (car result) 0)))))

;; Test 4: Script adds resource to scheme section
(test "Script adds resource to scheme section"
      (lambda ()
        (setup-test-env)
        (create-test-file (string-append test-pages-dir "/index.scm") test-index-content)
        (let* ((result (run-add-resource
                        '("scheme"
                          "New Resource"
                          "https://newresource.com"
                          "A brand new resource"
                          "[\"tag1\", \"tag2\"]")))
               (output (cdr result)))
          (cleanup-test-env)
          (and (= (car result) 0)
               (string-contains output "New Resource")
               (string-contains output "https://newresource.com")
               (string-contains output "A brand new resource")
               (string-contains output "tag1")
               (string-contains output "tag2")))))

;; Test 5: Output is valid Scheme
(test "Script output is valid Scheme"
      (lambda ()
        (setup-test-env)
        (create-test-file (string-append test-pages-dir "/index.scm") test-index-content)
        (let* ((result (run-add-resource
                        '("scheme"
                          "New Resource"
                          "https://newresource.com"
                          "Description"
                          "[\"tag\"]")))
               (output (cdr result)))
          (cleanup-test-env)
          (and (= (car result) 0)
               ;; Try to read the output
               (with-exception-handler
                 (lambda (exn) #f)
                 (lambda ()
                   (call-with-input-string output
                     (lambda (port)
                       (let loop ((forms '()))
                         (let ((form (read port)))
                           (if (eof-object? form)
                               #t
                               (loop (cons form forms)))))))
                   #t)
                 #:unwind? #t)))))

;; Test 6: --in-place flag modifies file
(test "Script modifies file with --in-place flag"
      (lambda ()
        (setup-test-env)
        (create-test-file (string-append test-pages-dir "/index.scm") test-index-content)
        (let* ((result (run-add-resource
                        '("--in-place"
                          "scheme"
                          "In-Place Resource"
                          "https://inplace.com"
                          "Test in-place"
                          "[\"test\"]")))
               (modified-content (call-with-input-file (string-append test-pages-dir "/index.scm")
                                   get-string-all)))
          (cleanup-test-env)
          (and (= (car result) 0)
               (string-contains modified-content "In-Place Resource")
               (string-contains modified-content "https://inplace.com")))))

;; Test 7: Preserves existing resources
(test "Script preserves existing resources"
      (lambda ()
        (setup-test-env)
        (create-test-file (string-append test-pages-dir "/index.scm") test-index-content)
        (let* ((result (run-add-resource
                        '("scheme"
                          "New Resource"
                          "https://new.com"
                          "New"
                          "[\"tag\"]")))
               (output (cdr result)))
          (cleanup-test-env)
          (and (= (car result) 0)
               (string-contains output "Existing Resource")
               (string-contains output "New Resource")))))

;; Test 8: Rejects dangerous characters in strings
(test "Script rejects unescaped quotes in input"
      (lambda ()
        (setup-test-env)
        (create-test-file (string-append test-pages-dir "/index.scm") test-index-content)
        (let* ((result (run-add-resource
                        '("scheme"
                          "Resource \"with quotes\""
                          "https://test.com"
                          "Description"
                          "[\"tag\"]")))
               (exit-code (car result)))
          (cleanup-test-env)
          ;; Should fail with exit code 5 (validation failed)
          (= exit-code 5))))

;; Test 9: Adds to common-lisp section
(test "Script adds resource to common-lisp section"
      (lambda ()
        (setup-test-env)
        (create-test-file (string-append test-pages-dir "/index.scm") test-index-content)
        (let* ((result (run-add-resource
                        '("common-lisp"
                          "CL New Resource"
                          "https://cl-new.com"
                          "New CL resource"
                          "[\"cl\", \"new\"]")))
               (output (cdr result)))
          (cleanup-test-env)
          (and (= (car result) 0)
               (string-contains output "CL New Resource")
               (string-contains output "https://cl-new.com")
               (string-contains output "CL Resource")))))  ; existing resource

;; Print summary
(format #t "~%Tests: ~a/~a passed~%" pass-count test-count)
(exit (if (= pass-count test-count) 0 1))
