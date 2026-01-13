(use-modules (haunt asset)
             (haunt builder assets)
             (haunt html)
             (haunt page)
             (haunt site)
             (srfi srfi-1)
             (ice-9 match)
             (sxml simple))

;; Load our custom modules
(add-to-load-path (getcwd))
(use-modules (templates base)
             (pages index))

;; Build the index page
(define (index-page site posts)
  (make-page "index.html"
             (base-template site (index-content))
             sxml->html))

;; Site configuration
(site #:title "sexp-ed"
      #:domain "sexp-ed.com"
      #:default-metadata
      '((author . "sexp-ed contributors"))
      #:builders (list (lambda (site posts)
                         (list (index-page site posts)))
                       (static-directory "assets")))
