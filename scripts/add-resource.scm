#!/usr/bin/env guile
!#

;;; Add a resource card to pages/index.scm by TEXT insertion, so comments,
;;; formatting and every other section stay byte-for-byte intact.
;;; Usage: ./scripts/add-resource.scm [--in-place] <section-id> <title> <url> <description> <tags-json>
;;; Env: INDEX_FILE overrides the target (default pages/index.scm; used by tests).
;;;
;;; Exit codes: 1 bad args, 2 file not found, 3 parse error, 4 section not found, 5 validation failed

(use-modules (ice-9 textual-ports)
             (ice-9 regex)
             (srfi srfi-1))

(define section-map
  '(("general" . "general-section") ("common-lisp" . "common-lisp-section")
    ("scheme" . "scheme-section") ("racket" . "racket-section")
    ("clojure" . "clojure-section") ("emacs-lisp" . "emacs-lisp-section")
    ("janet" . "janet-section") ("others" . "others-section")))

(define (die code fmt . args)
  (apply format (current-error-port) (string-append "Error: " fmt "~%") args)
  (exit code))

;; Scheme string literal with \ and " escaped.
(define (quote-str s)
  (call-with-output-string
   (lambda (p)
     (write-char #\" p)
     (string-for-each (lambda (c)
                        (when (memv c '(#\" #\\)) (write-char #\\ p))
                        (write-char (if (char=? c #\newline) #\space c) p))
                      s)
     (write-char #\" p))))

;; ["a", "b"] -> ("a" "b"); #f if malformed. Tags become CSS classes, so restrict chars.
(define (parse-tags json)
  (let ((m (string-match "^\\[(.*)\\]$" (string-trim-both json))))
    (and m
         (let ((body (string-trim-both (match:substring m 1))))
           (if (string-null? body)
               '()
               (let ((tags (map (lambda (t)
                                  (let ((t (string-trim-both t)))
                                    (if (string-match "^\"[A-Za-z0-9_-]+\"$" t)
                                        (substring t 1 (- (string-length t) 1))
                                        #f)))
                                (string-split body #\,))))
                 (and (every values tags) tags)))))))

;; Index of the ")" closing the "(" at START. Skips strings, ; comments, #\x chars.
(define (matching-paren text start)
  (let ((n (string-length text)))
    (let loop ((i start) (depth 0))
      (and (< i n)
           (let ((c (string-ref text i)))
             (cond
              ((char=? c #\") (loop (let s ((j (+ i 1)))
                                      (cond ((>= j n) n)
                                            ((char=? (string-ref text j) #\\) (s (+ j 2)))
                                            ((char=? (string-ref text j) #\") (+ j 1))
                                            (else (s (+ j 1)))))
                                    depth))
              ((char=? c #\;) (loop (or (string-index text #\newline i) n) depth))
              ((and (char=? c #\#) (< (+ i 1) n) (char=? (string-ref text (+ i 1)) #\\))
               (loop (+ i 3) depth))
              ((char=? c #\() (loop (+ i 1) (+ depth 1)))
              ((char=? c #\)) (if (= depth 1) i (loop (+ i 1) (- depth 1))))
              (else (loop (+ i 1) depth))))))))

;; New text with CARD inserted at the end of the section's resources-grid, or #f.
(define (insert-card text fn card)
  (let* ((def (string-contains text (string-append "(define (" fn ")")))
         (next (and def (string-contains text "\n(define " (+ def 1))))
         (grid (and def (string-contains text "(div (@ (class \"resources-grid\"))" def)))
         (close (and grid (or (not next) (< grid next)) (matching-paren text grid))))
    (and close
         (string-append (substring text 0 close)
                        "\n                 ,(resource-card\n                   "
                        (string-join (list (quote-str (list-ref card 0)) (quote-str (list-ref card 1))
                                           (quote-str (list-ref card 2))
                                           (string-append "'(" (string-join (map quote-str (list-ref card 3)) " ") ")"))
                                     "\n                   ")
                        ")"
                        (substring text close)))))

(define (readable? text)
  (catch #t
    (lambda ()
      (call-with-input-string text
        (lambda (p) (let loop () (or (eof-object? (read p)) (loop))))))
    (lambda _ #f)))

(define (main args)
  (let* ((in-place (and (pair? (cdr args)) (string=? (cadr args) "--in-place")))
         (rest (if in-place (cddr args) (cdr args)))
         (file (or (getenv "INDEX_FILE") "pages/index.scm")))
    (when (< (length rest) 5)
      (die 1 "usage: ~a [--in-place] <section-id> <title> <url> <description> <tags-json>" (car args)))
    (let* ((section (list-ref rest 0)) (title (list-ref rest 1)) (url (list-ref rest 2))
           (desc (list-ref rest 3)) (tags (parse-tags (list-ref rest 4)))
           (fn (assoc-ref section-map section)))
      (unless (access? file R_OK) (die 2 "file not found: ~a" file))
      (unless fn (die 4 "unknown section: ~a" section))
      (when (or (string-null? title) (> (string-length title) 200)) (die 5 "bad title"))
      (when (or (string-null? desc) (> (string-length desc) 1000)) (die 5 "bad description"))
      (unless (and (<= (string-length url) 500) (string-match "^https?://[^ \"\\]+$" url))
        (die 5 "bad url"))
      (unless tags (die 5 "invalid tags JSON"))
      (let ((text (call-with-input-file file get-string-all)))
        (unless (readable? text) (die 3 "~a does not parse" file))
        (let ((new (insert-card text fn (list title url desc tags))))
          (unless new (die 4 "section/grid not found: ~a" fn))
          (unless (readable? new) (die 5 "generated content does not parse"))
          (if in-place
              (let ((tmp (string-append file ".tmp")))
                (call-with-output-file tmp (lambda (p) (display new p)))
                (rename-file tmp file)
                (format #t "✓ Resource added to ~a~%" file))
              (display new)))))))

(main (command-line))
