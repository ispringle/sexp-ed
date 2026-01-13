(define-module (templates base)
  #:use-module (haunt html)
  #:use-module (haunt site)
  #:export (base-template))

(define (navigation)
  `(nav (@ (class "nav"))
        (div (@ (class "nav-brand"))
             (a (@ (href "/"))
                (span (@ (class "paren")) "(")
                "sexp-ed"
                (span (@ (class "paren")) ")")))
        (ul (@ (class "nav-links"))
            (li (a (@ (href "#intro")) "Intro"))
            (li (a (@ (href "#try-it")) "Try It"))
            (li (a (@ (href "#history")) "History"))
            (li (a (@ (href "#common-lisp")) "Common Lisp"))
            (li (a (@ (href "#scheme")) "Scheme"))
            (li (a (@ (href "#racket")) "Racket"))
            (li (a (@ (href "#clojure")) "Clojure"))
            (li (a (@ (href "#emacs-lisp")) "Emacs Lisp"))
            (li (a (@ (href "#janet")) "Janet"))
            (li (a (@ (href "#others")) "Others")))))

(define (footer)
  `(footer (@ (class "footer"))
           (div (@ (class "footer-content"))
                (p (@ (class "footer-parens"))
                   (span (@ (class "paren open")) "(")
                   "Made with "
                   (a (@ (class "ghost")
                         (href "https://dthompson.us/projects/haunt.html")
                         (target "_blank")
                         (rel "noopener noreferrer")
                         (title "Built with Haunt"))
                      "👻")
                   " and lots of parentheses"
                   (span (@ (class "paren close")) ")"))
                (p (@ (class "footer-links"))
                   "Contribute on "
                   (a (@ (href "https://github.com/ispringle/sexp-ed")
                         (target "_blank")
                         (rel "noopener noreferrer"))
                      "GitHub")))))

(define (base-template site content)
  `(html (@ (lang "en"))
         (head
          (meta (@ (charset "utf-8")))
          (meta (@ (name "viewport")
                   (content "width=device-width, initial-scale=1")))
          (title ,(site-title site) " - Learn Lisp")
          (meta (@ (name "description")
                   (content "A curated collection of resources to learn Lisp and its many dialects: Common Lisp, Scheme, Clojure, Racket, Emacs Lisp, Janet, and more.")))
          (link (@ (rel "preconnect")
                   (href "https://fonts.googleapis.com")))
          (link (@ (rel "preconnect")
                   (href "https://fonts.gstatic.com")
                   (crossorigin "")))
          (link (@ (rel "stylesheet")
                   (href "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,600;9..144,700&family=Atkinson+Hyperlegible:wght@400;700&family=JetBrains+Mono:wght@400;500&display=swap")))
          (link (@ (rel "stylesheet")
                   (href "/assets/css/style.css")))
          (link (@ (rel "icon")
                   (type "image/svg+xml")
                   (href "/assets/favicon.svg")))
          ;; LIPS Scheme REPL dependencies
          (link (@ (rel "stylesheet")
                   (href "https://cdn.jsdelivr.net/npm/jquery.terminal/css/jquery.terminal.min.css")))
          (link (@ (rel "stylesheet")
                   (href "https://cdn.jsdelivr.net/npm/lips@beta/lib/css/terminal.css"))))
         (body
          ,(navigation)
          (main (@ (class "main"))
                ,content)
          ,(footer)
          ;; LIPS Scheme REPL scripts (loaded at end of body for performance)
          (script (@ (src "https://cdn.jsdelivr.net/npm/jquery")))
          (script (@ (src "https://cdn.jsdelivr.net/npm/jquery.terminal/js/jquery.terminal.min.js")))
          (script (@ (src "https://cdn.jsdelivr.net/npm/prismjs/prism.js")))
          (script (@ (src "https://cdn.jsdelivr.net/npm/jquery.terminal/js/prism.js")))
          (script (@ (src "https://cdn.jsdelivr.net/npm/prismjs/components/prism-scheme.min.js")))
          (script (@ (src "https://cdn.jsdelivr.net/npm/lips@beta/dist/lips.min.js")
                     (bootstrap "")))
          (script (@ (src "https://cdn.jsdelivr.net/npm/lips@beta/lib/js/terminal.js")))
          (script "
$(function() {
    if ($('#repl').length) {
        $.terminal.syntax('scheme');
        var term = terminal({
            selector: '#repl',
            dynamic: false,
            name: 'sexp-ed-repl',
            lips: lips,
            height: 280
        });
        term.echo('Welcome! Click an example above or try: (+ 1 2 3)', { formatters: false });
        
        // Make examples clickable
        $('.repl-example').on('click', function() {
            var code = $(this).text();
            term.insert(code);
            // Scroll REPL into view, then focus after scroll settles
            $('#repl')[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
            setTimeout(function() { term.focus(); }, 300);
        });
    }
});
"))))
