(define-module (pages index)
  #:export (index-content))

(define (resource-card title url description tags)
  `(article (@ (class "resource-card"))
            (h4 (@ (class "resource-title"))
                (a (@ (href ,url)
                      (target "_blank")
                      (rel "noopener noreferrer"))
                   ,title))
            (p (@ (class "resource-description")) ,description)
            (div (@ (class "resource-tags"))
                 ,@(map (lambda (tag)
                          `(span (@ (class ,(string-append "tag tag-" tag))) ,tag))
                        tags))))

(define (scheme-section)
  `(section (@ (id "scheme") (class "section dialect scheme"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Scheme"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "Existing Resource"
                   "https://example.com"
                   "An existing resource"
                   '("tag1" "tag2")))))

(define (common-lisp-section)
  `(section (@ (id "common-lisp") (class "section dialect cl"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Common Lisp"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "CL Resource"
                   "https://example.com/cl"
                   "A Common Lisp resource"
                   '("cl")))))

(define (general-section)
  `(section (@ (id "general") (class "section dialect general"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "General"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid")))))

(define (racket-section)
  `(section (@ (id "racket") (class "section dialect racket"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Racket"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid")))))

(define (clojure-section)
  `(section (@ (id "clojure") (class "section dialect clojure"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Clojure"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid")))))

(define (emacs-lisp-section)
  `(section (@ (id "emacs-lisp") (class "section dialect elisp"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Emacs Lisp"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid")))))

(define (janet-section)
  `(section (@ (id "janet") (class "section dialect janet"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Janet"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid")))))

(define (others-section)
  `(section (@ (id "others") (class "section dialect others"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Other Lisps"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid")))))

(define (index-content)
  `(div (@ (class "content"))
        ,(general-section)
        ,(scheme-section)
        ,(racket-section)
        ,(common-lisp-section)
        ,(clojure-section)
        ,(emacs-lisp-section)
        ,(janet-section)
        ,(others-section)))
