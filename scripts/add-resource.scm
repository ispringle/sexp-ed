#!/usr/bin/env guile
!#

;;; Add a resource to pages/index.scm
;;; Usage: ./scripts/add-resource.scm <section-id> <title> <url> <description> <tags-json>
;;;
;;; Example:
;;;   ./scripts/add-resource.scm scheme "Sigil" "https://usesigil.org/" "Great Scheme impl" '["reference", "free"]'
;;;
;;; Exit codes:
;;;   0 - Success
;;;   1 - Invalid arguments
;;;   2 - File not found
;;;   3 - Parse/syntax error
;;;   4 - Section not found
;;;   5 - Validation failed

(use-modules (ice-9 format)
             (ice-9 exceptions)
             (ice-9 textual-ports)
             (ice-9 regex)
             (ice-9 pretty-print))

;; Maximum length constraints to prevent abuse
(define max-title-length 200)
(define max-url-length 500)
(define max-description-length 1000)

;; Section ID to function name mapping
(define section-map
  '(("general" . general-section)
    ("common-lisp" . common-lisp-section)
    ("scheme" . scheme-section)
    ("racket" . racket-section)
    ("clojure" . clojure-section)
    ("emacs-lisp" . emacs-lisp-section)
    ("janet" . janet-section)
    ("others" . others-section)))

;; Get function name from section ID
(define (section-id->function section-id)
  (assoc-ref section-map section-id))

;; Validate URL format
(define (validate-url url)
  (and (string? url)
       (<= (string-length url) max-url-length)
       (or (string-prefix? "http://" url)
           (string-prefix? "https://" url))))

;; Check if string contains problematic unescaped characters
(define (contains-unescaped-quotes? str)
  (let ((len (string-length str)))
    (let loop ((i 0))
      (if (>= i len)
          #f
          (let ((ch (string-ref str i)))
            (if (and (char=? ch #\")
                     (or (= i 0)
                         (not (char=? (string-ref str (- i 1)) #\\))))
                #t
                (loop (+ i 1))))))))

;; Validate input string
(define (validate-input-string str name max-len)
  (cond
   ((not (string? str))
    (cons #f (format #f "~a must be a string" name)))
   ((> (string-length str) max-len)
    (cons #f (format #f "~a exceeds maximum length of ~a characters" name max-len)))
   ((string-null? str)
    (cons #f (format #f "~a cannot be empty" name)))
   ((contains-unescaped-quotes? str)
    (cons #f (format #f "~a contains unescaped quotes that could break parsing" name)))
   (else
    (cons #t str))))

;; Simple JSON array parser for tags
;; Expects format: ["tag1", "tag2", "tag3"]
(define (parse-tags-json json-str)
  (with-exception-handler
    (lambda (exn)
      (format (current-error-port) "Error parsing tags JSON: ~a~%" exn)
      #f)
    (lambda ()
      ;; Remove brackets and whitespace
      (let* ((cleaned (string-trim-both json-str))
             (without-brackets (if (and (string-prefix? "[" cleaned)
                                       (string-suffix? "]" cleaned))
                                  (substring cleaned 1 (- (string-length cleaned) 1))
                                  cleaned))
             (without-spaces (string-trim-both without-brackets)))
        ;; Split by comma and extract quoted strings
        (if (string-null? without-spaces)
            '()
            (let ((parts (string-split without-spaces #\,)))
              (map (lambda (part)
                     (let* ((trimmed (string-trim-both part))
                            ;; Remove quotes
                            (unquoted (if (and (string-prefix? "\"" trimmed)
                                              (string-suffix? "\"" trimmed))
                                         (substring trimmed 1 (- (string-length trimmed) 1))
                                         trimmed)))
                       unquoted))
                   parts)))))
    #:unwind? #t))

;; Find a form in a list of forms that matches a pattern
;; Pattern is (define (function-name) ...)
(define (find-define-form forms function-name)
  (let loop ((remaining forms))
    (if (null? remaining)
        #f
        (let ((form (car remaining)))
          (if (and (list? form)
                   (>= (length form) 3)
                   (eq? (car form) 'define)
                   (list? (cadr form))
                   (>= (length (cadr form)) 1)
                   (eq? (car (cadr form)) function-name))
              form
              (loop (cdr remaining)))))))

;; Find the resources-grid div within a section form
(define (find-resources-grid form)
  (let recurse ((node form))
    (cond
     ((not (list? node)) #f)
     ((null? node) #f)
     ;; Check if this is the resources-grid div
     ((and (list? node)
           (>= (length node) 2)
           (eq? (car node) 'div)
           (list? (cadr node))
           (>= (length (cadr node)) 1)
           (eq? (car (cadr node)) '@)
           (member '(class "resources-grid") (cdr (cadr node))))
      node)
     ;; Recurse into sublists
     (else
      (let loop ((items node))
        (if (null? items)
            #f
            (let ((result (recurse (car items))))
              (if result
                  result
                  (loop (cdr items))))))))))

;; Insert a new resource card into the resources-grid
(define (insert-resource-card grid-form title url description tags)
  (if (not grid-form)
      #f
      (let* ((grid-attrs (cadr grid-form))
             (existing-cards (cddr grid-form))
             ;; Build the form: ,(resource-card "title" "url" "desc" '("tag1" "tag2"))
             ;; This is represented as: (unquote (resource-card ...))
             (new-card (list 'unquote
                            (list 'resource-card
                                  title
                                  url
                                  description
                                  (list 'quote tags)))))
        ;; Reconstruct the div with all cards
        (cons 'div (cons grid-attrs (append existing-cards (list new-card)))))))

;; Replace a subform in a tree
(define (replace-in-tree tree old-form new-form)
  (cond
   ((equal? tree old-form) new-form)
   ((not (list? tree)) tree)
   ((null? tree) tree)
   (else (map (lambda (item) (replace-in-tree item old-form new-form)) tree))))

;; Process the file: read, modify, return new content
(define (add-resource-to-file filepath section-id title url description tags)
  (with-exception-handler
    (lambda (exn)
      (format (current-error-port) "Error reading file: ~a~%" exn)
      #f)
    (lambda ()
      ;; Read all forms from the file
      (let* ((forms (call-with-input-file filepath
                      (lambda (port)
                        (let loop ((forms '()))
                          (let ((form (read port)))
                            (if (eof-object? form)
                                (reverse forms)
                                (loop (cons form forms))))))))
             (function-name (section-id->function section-id)))

        (if (not function-name)
            (begin
              (format (current-error-port) "Error: Invalid section ID: ~a~%" section-id)
              #f)
            (let* ((section-form (find-define-form forms function-name)))
              (if (not section-form)
                  (begin
                    (format (current-error-port) "Error: Section function not found: ~a~%" function-name)
                    #f)
                  (let* ((grid-form (find-resources-grid section-form)))
                    (if (not grid-form)
                        (begin
                          (format (current-error-port) "Error: resources-grid not found in section~%")
                          #f)
                        (let* ((new-grid (insert-resource-card grid-form title url description tags))
                               (new-section (replace-in-tree section-form grid-form new-grid))
                               (new-forms (map (lambda (form)
                                                 (if (equal? form section-form)
                                                     new-section
                                                     form))
                                               forms)))
                          new-forms))))))))
    #:unwind? #t))

;; Write forms to a port with proper formatting
(define (write-forms forms port)
  (for-each (lambda (form)
              (pretty-print form port)
              (newline port))
            forms))

;; Validate the modified content by trying to read it
(define (validate-content content)
  (with-exception-handler
    (lambda (exn)
      (format (current-error-port) "Validation error: ~a~%" exn)
      #f)
    (lambda ()
      (call-with-input-string content
        (lambda (port)
          (let loop ()
            (let ((form (read port)))
              (if (eof-object? form)
                  #t
                  (loop))))))
      #t)
    #:unwind? #t))

;; Atomic file write: write to temp file, validate, then rename
(define (atomic-write-file filepath content)
  (let* ((temp-file (string-append filepath ".tmp." (number->string (getpid))))
         (backup-file (string-append filepath ".bak")))
    (with-exception-handler
      (lambda (exn)
        ;; Clean up temp file on error
        (when (file-exists? temp-file)
          (delete-file temp-file))
        (format (current-error-port) "Error writing file: ~a~%" exn)
        #f)
      (lambda ()
        ;; Write to temp file
        (with-output-to-file temp-file
          (lambda ()
            (display content)))

        ;; Validate temp file can be loaded
        (call-with-input-file temp-file
          (lambda (port)
            (let loop ()
              (let ((form (read port)))
                (if (eof-object? form)
                    #t
                    (loop))))))

        ;; Create backup of original
        (when (file-exists? filepath)
          (copy-file filepath backup-file))

        ;; Atomic rename
        (rename-file temp-file filepath)

        ;; Clean up backup on success
        (when (file-exists? backup-file)
          (delete-file backup-file))

        #t)
      #:unwind? #t)))

;; Main function
(define (main args)
  (let* ((args-list (cdr args))  ; Remove program name
         (in-place (and (>= (length args-list) 1)
                        (string=? (car args-list) "--in-place")))
         (actual-args (if in-place (cdr args-list) args-list))
         (filepath "pages/index.scm"))  ; Hardcoded target file

    ;; Check argument count (expecting 5 arguments: section-id, title, url, description, tags-json)
    (if (< (length actual-args) 5)
        (begin
          (format (current-error-port) "Usage: ~a [--in-place] <section-id> <title> <url> <description> <tags-json>~%" (car args))
          (format (current-error-port) "~%")
          (format (current-error-port) "Example:~%")
          (format (current-error-port) "  ~a scheme \"Sigil\" \"https://usesigil.org/\" \"Great Scheme impl\" '[\"reference\", \"free\"]'~%" (car args))
          (format (current-error-port) "  ~a --in-place scheme \"Sigil\" \"https://usesigil.org/\" \"Great Scheme impl\" '[\"reference\", \"free\"]'~%" (car args))
          (exit 1))

        (let* ((section-id (car actual-args))
               (title (cadr actual-args))
               (url (caddr actual-args))
               (description (cadddr actual-args))
               (tags-json (list-ref actual-args 4)))

          ;; Validate inputs
          (let ((title-result (validate-input-string title "Title" max-title-length))
                (desc-result (validate-input-string description "Description" max-description-length)))

            (if (not (car title-result))
                (begin
                  (format (current-error-port) "Error: ~a~%" (cdr title-result))
                  (exit 5))
                (if (not (car desc-result))
                    (begin
                      (format (current-error-port) "Error: ~a~%" (cdr desc-result))
                      (exit 5))
                    (if (not (validate-url url))
                        (begin
                          (format (current-error-port) "Error: URL must start with http:// or https:// and be less than ~a characters~%" max-url-length)
                          (exit 5))

                        (let ((tags (parse-tags-json tags-json)))
                          ;; Check if file exists
                          (if (not (access? filepath R_OK))
                              (begin
                                (format (current-error-port) "Error: File not found: ~a~%" filepath)
                                (exit 2))

                              ;; Parse tags
                              (if (not tags)
                                  (begin
                                    (format (current-error-port) "Error: Invalid tags JSON~%")
                                    (exit 5))

                                  ;; Process file
                                  (let ((new-forms (add-resource-to-file filepath section-id title url description tags)))
                                    (if (not new-forms)
                                        (exit 4)

                                        ;; Generate output
                                        (let ((output (call-with-output-string
                                                       (lambda (port)
                                                         (write-forms new-forms port)))))

                                          ;; Validate output
                                          (if (not (validate-content output))
                                              (begin
                                                (format (current-error-port) "Error: Generated content is invalid Scheme~%")
                                                (exit 5))

                                              ;; Write output
                                              (if in-place
                                                  (if (atomic-write-file filepath output)
                                                      (begin
                                                        (format #t "✓ Resource added to ~a~%" filepath)
                                                        (exit 0))
                                                      (begin
                                                        (format (current-error-port) "Error: Failed to write file atomically~%")
                                                        (exit 5)))
                                                  (begin
                                                    (display output)
                                                    (exit 0)))))))))))))))))

)

;; Run main
(main (command-line))
