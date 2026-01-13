(define-module (pages index)
  #:export (index-content))

;; Helper to create a resource card
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

;; Hero section
(define (hero-section)
  `(section (@ (id "intro") (class "section hero"))
            (div (@ (class "hero-content"))
                 (h1 (@ (class "hero-title"))
                     (span (@ (class "paren animated")) "(")
                     "Learn Lisp"
                     (span (@ (class "paren animated")) ")"))
                 (p (@ (class "hero-subtitle"))
                    "A curated collection of resources to master the most elegant family of programming languages")
                 (div (@ (class "hero-sexpr"))
                      (code "(journey (from 'curious) (to 'enlightened))")))
            (div (@ (class "floating-parens"))
                 (span (@ (class "float-paren p1")) "(")
                 (span (@ (class "float-paren p2")) ")")
                 (span (@ (class "float-paren p3")) "(")
                 (span (@ (class "float-paren p4")) ")")
                 (span (@ (class "float-paren p5")) "(")
                 (span (@ (class "float-paren p6")) ")"))))

;; REPL section - Interactive Scheme playground
(define (repl-section)
  `(section (@ (id "try-it") (class "section repl-section"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Try It"
                (span (@ (class "paren")) ")"))
            (p (@ (class "section-intro"))
               "Experience Lisp right here! This is a fully functional Scheme REPL powered by "
               (a (@ (href "https://lips.js.org/")
                     (target "_blank")
                     (rel "noopener noreferrer"))
                  "LIPS Scheme")
               ". Try evaluating some expressions:")
            (div (@ (class "repl-examples"))
                 (code (@ (class "repl-example")) "(+ 1 2 3 4 5)")
                 (code (@ (class "repl-example")) "(define (square x) (* x x))")
                 (code (@ (class "repl-example")) "(map square '(1 2 3 4 5))"))
            (div (@ (id "repl") (class "repl-container")))))

;; History section
(define (history-section)
  `(section (@ (id "history") (class "section history"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "A Brief History"
                (span (@ (class "paren")) ")"))
            (div (@ (class "timeline"))
                 (div (@ (class "timeline-item"))
                      (div (@ (class "timeline-year")) "1958")
                      (div (@ (class "timeline-content"))
                           (h3 "The Birth of Lisp")
                           (p "John McCarthy creates Lisp at MIT, making it the second-oldest high-level programming language still in use today (after Fortran).")))
                 (div (@ (class "timeline-item"))
                      (div (@ (class "timeline-year")) "1975")
                      (div (@ (class "timeline-content"))
                           (h3 "Scheme Emerges")
                           (p "Gerald Jay Sussman and Guy L. Steele Jr. create Scheme, a minimalist dialect emphasizing lexical scoping and tail-call optimization.")))
                 (div (@ (class "timeline-item"))
                      (div (@ (class "timeline-year")) "1984")
                      (div (@ (class "timeline-content"))
                           (h3 "Common Lisp Standard")
                           (p "Common Lisp is standardized, unifying many Lisp dialects into a powerful, feature-rich language.")))
                 (div (@ (class "timeline-item"))
                      (div (@ (class "timeline-year")) "2007")
                      (div (@ (class "timeline-content"))
                           (h3 "Clojure Arrives")
                           (p "Rich Hickey releases Clojure, bringing Lisp to the JVM with immutable data structures and modern concurrency primitives.")))
                 (div (@ (class "timeline-item"))
                      (div (@ (class "timeline-year")) "2017+")
                      (div (@ (class "timeline-content"))
                           (h3 "The Renaissance")
                           (p "New dialects like Janet, Fennel, and Hy bring Lisp ideas to embedded systems, game development, and Python interop."))))))

;; General resources section
(define (general-section)
  `(section (@ (id "general") (class "section general"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "General Lisp Resources"
                (span (@ (class "paren")) ")"))
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "Structure and Interpretation of Computer Programs"
                   "https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/index.html"
                   "The legendary SICP textbook - a masterpiece of computer science education using Scheme."
                   '("book" "free" "classic"))
                 ,(resource-card
                   "The Little Schemer"
                   "https://mitpress.mit.edu/9780262560993/the-little-schemer/"
                   "A delightful, mind-bending introduction to recursive thinking and Lisp through Socratic dialogue."
                   '("book" "beginner"))
                 ,(resource-card
                   "Lisp: A Language for Stratified Design"
                   "https://dspace.mit.edu/handle/1721.1/6064"
                   "Harold Abelson and Gerald Sussman's paper on why Lisp is ideal for building complex systems."
                   '("paper" "free"))
                 ,(resource-card
                   "Paul Graham's Lisp Essays"
                   "http://www.paulgraham.com/lisp.html"
                   "Influential essays on Lisp including 'Beating the Averages' and 'What Made Lisp Different'."
                   '("essays" "free")))))

;; Common Lisp section
(define (common-lisp-section)
  `(section (@ (id "common-lisp") (class "section dialect cl"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Common Lisp"
                (span (@ (class "paren")) ")"))
            (p (@ (class "section-intro"))
               "The industrial-strength Lisp with an extensive standard library, powerful metaprogramming, and decades of real-world use.")
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "Practical Common Lisp"
                   "https://gigamonkeys.com/book/"
                   "Peter Seibel's modern, practical introduction to Common Lisp. Available free online."
                   '("book" "free" "beginner"))
                 ,(resource-card
                   "Common Lisp: A Gentle Introduction"
                   "https://www.cs.cmu.edu/~dst/LispBook/"
                   "David Touretzky's beginner-friendly book with a focus on symbolic computation."
                   '("book" "free" "beginner"))
                 ,(resource-card
                   "On Lisp"
                   "http://www.paulgraham.com/onlisp.html"
                   "Paul Graham's advanced exploration of Lisp macros and bottom-up programming."
                   '("book" "free" "advanced"))
                 ,(resource-card
                   "Let Over Lambda"
                   "https://letoverlambda.com/"
                   "Doug Hoyte's deep dive into closures and advanced macro techniques."
                   '("book" "advanced"))
                 ,(resource-card
                   "Common Lisp HyperSpec"
                   "http://www.lispworks.com/documentation/HyperSpec/Front/"
                   "The complete ANSI Common Lisp specification - the authoritative reference."
                   '("reference" "free"))
                 ,(resource-card
                   "Lisp-Lang.org"
                   "https://lisp-lang.org/"
                   "Modern Common Lisp community site with tutorials, library documentation, and success stories."
                   '("community" "free"))
                 ,(resource-card
                   "SBCL"
                   "http://www.sbcl.org/"
                   "Steel Bank Common Lisp - a high-performance, open source Common Lisp compiler."
                   '("implementation" "free"))
                 ,(resource-card
                   "Portacle"
                   "https://portacle.github.io/"
                   "A portable, multiplatform Common Lisp development environment. Perfect for beginners."
                   '("tool" "free" "beginner")))))

;; Scheme section
(define (scheme-section)
  `(section (@ (id "scheme") (class "section dialect scheme"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Scheme"
                (span (@ (class "paren")) ")"))
            (p (@ (class "section-intro"))
               "The minimalist Lisp that proves less is more. Scheme's elegance makes it ideal for teaching and language research.")
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "The Scheme Programming Language"
                   "https://www.scheme.com/tspl4/"
                   "R. Kent Dybvig's comprehensive guide to Scheme, covering R6RS."
                   '("book" "free" "reference"))
                 ,(resource-card
                   "How to Design Programs"
                   "https://htdp.org/"
                   "A systematic approach to program design using Racket/Scheme. Great for beginners."
                   '("book" "free" "beginner"))
                 ,(resource-card
                   "CHICKEN Scheme"
                   "https://www.call-cc.org/"
                   "A practical Scheme that compiles to C. Great FFI and egg repository."
                   '("implementation" "free"))
                 ,(resource-card
                   "Guile"
                   "https://www.gnu.org/software/guile/"
                   "GNU's official extension language. Powers Guix, LilyPond, and more."
                   '("implementation" "free"))
                 ,(resource-card
                   "Chez Scheme"
                   "https://cisco.github.io/ChezScheme/"
                   "One of the fastest Scheme implementations, now open source."
                   '("implementation" "free"))
                 ,(resource-card
                   "Scheme Wiki"
                   "http://community.schemewiki.org/"
                   "Community wiki with tutorials, idioms, and implementation comparisons."
                   '("community" "free"
                 ,(resource-card
       "Sigil"
       "https://usesigil.org/"
       "This website is missing the Sigil language that is a Scheme implementation. Here is the excerpt from the Sigil's website:
```
Craft software worth sharing.

Sigil is a Scheme for people who want to make things — tools, games, utilities, creative projects — and share them with others. Write your program, compile it to a single binary, and give it to anyone. No runtime, no dependencies, no installation instructions. Just software that works.
A Scheme That Ships

Most Schemes are for learning or research. Sigil is for building.

You get the elegance of Scheme — simple syntax, powerful macros, REPL-driven development — combined with everything you need to make real programs: file I/O, networking, JSON, concurrency, and more. When you're done, sigil build produces a standalone executable you can send to anyone.

The language is small enough to feel personal. The tools are practical enough to be useful. The binaries are small enough to be delightful.
```"
       '("reference" "implementation" "free")))))))

;; Racket section
(define (racket-section)
  `(section (@ (id "racket") (class "section dialect racket"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Racket"
                (span (@ (class "paren")) ")"))
            (p (@ (class "section-intro"))
               "The \"language-oriented programming\" language. Build your own languages with Racket's unmatched DSL capabilities.")
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "The Racket Guide"
                   "https://docs.racket-lang.org/guide/"
                   "The official introduction to Racket - well-written and comprehensive."
                   '("guide" "free" "beginner"))
                 ,(resource-card
                   "Beautiful Racket"
                   "https://beautifulracket.com/"
                   "Matthew Butterick's guide to making languages with Racket. Inspiring and practical."
                   '("book" "advanced"))
                 ,(resource-card
                   "Realm of Racket"
                   "https://nostarch.com/realmofracket.htm"
                   "Learn Racket by building games. Fun illustrated approach."
                   '("book" "beginner"))
                 ,(resource-card
                   "Racket Documentation"
                   "https://docs.racket-lang.org/"
                   "Exemplary documentation covering the language and all bundled packages."
                   '("reference" "free"))
                 ,(resource-card
                   "Racket Discord"
                   "https://discord.gg/6Zq8sH5"
                   "Active community chat for Racket programmers of all levels."
                   '("community" "free")))))

;; Clojure section
(define (clojure-section)
  `(section (@ (id "clojure") (class "section dialect clojure"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Clojure"
                (span (@ (class "paren")) ")"))
            (p (@ (class "section-intro"))
               "Modern Lisp for the JVM, JavaScript, and CLR. Immutable data, functional programming, and practical concurrency.")
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "Clojure for the Brave and True"
                   "https://www.braveclojure.com/"
                   "Daniel Higginbotham's fun, irreverent introduction to Clojure. Free online."
                   '("book" "free" "beginner"))
                 ,(resource-card
                   "Clojure from the Ground Up"
                   "https://aphyr.com/tags/Clojure-from-the-ground-up"
                   "Kyle Kingsbury's (Aphyr) excellent tutorial series for beginners."
                   '("tutorial" "free" "beginner"))
                 ,(resource-card
                   "ClojureScript Unraveled"
                   "https://funcool.github.io/clojurescript-unraveled/"
                   "Comprehensive guide to ClojureScript for frontend development."
                   '("book" "free"))
                 ,(resource-card
                   "4Clojure"
                   "https://4clojure.oxal.org/"
                   "Practice Clojure with interactive coding exercises."
                   '("exercises" "free"))
                 ,(resource-card
                   "Clojure.org"
                   "https://clojure.org/"
                   "Official site with guides, references, and community resources."
                   '("reference" "free"))
                 ,(resource-card
                   "ClojureTV"
                   "https://www.youtube.com/user/ClojureTV"
                   "Conference talks and tutorials from Rich Hickey and the Clojure community."
                   '("video" "free"))
                 ,(resource-card
                   "Babashka"
                   "https://babashka.org/"
                   "Fast-starting Clojure for scripting. Write Clojure scripts that start instantly."
                   '("tool" "free")))))

;; Emacs Lisp section
(define (emacs-lisp-section)
  `(section (@ (id "emacs-lisp") (class "section dialect elisp"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Emacs Lisp"
                (span (@ (class "paren")) ")"))
            (p (@ (class "section-intro"))
               "The Lisp powering Emacs - one of the most extensible programs ever created. Customize everything.")
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "An Introduction to Programming in Emacs Lisp"
                   "https://www.gnu.org/software/emacs/manual/eintr.html"
                   "Official GNU tutorial for Emacs Lisp beginners."
                   '("book" "free" "beginner"))
                 ,(resource-card
                   "Emacs Lisp Reference Manual"
                   "https://www.gnu.org/software/emacs/manual/elisp.html"
                   "The complete reference for Emacs Lisp. Comprehensive and authoritative."
                   '("reference" "free"))
                 ,(resource-card
                   "Mastering Emacs"
                   "https://www.masteringemacs.org/"
                   "Mickey Petersen's excellent book on becoming an Emacs power user."
                   '("book" "advanced"))
                 ,(resource-card
                   "EmacsWiki"
                   "https://www.emacswiki.org/"
                   "Community wiki with tips, code snippets, and configuration ideas."
                   '("community" "free")))))

;; Janet section
(define (janet-section)
  `(section (@ (id "janet") (class "section dialect janet"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Janet"
                (span (@ (class "paren")) ")"))
            (p (@ (class "section-intro"))
               "A lightweight Lisp for scripting and system programming. Embeddable in applications like Lua, not to be confused with embedded devices.")
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "Janet Documentation"
                   "https://janet-lang.org/docs/index.html"
                   "Official documentation covering the language, standard library, and C API."
                   '("reference" "free"))
                 ,(resource-card
                   "Janet for Mortals"
                   "https://janet.guide/"
                   "A friendly introduction to Janet by Ian Henry."
                   '("tutorial" "free" "beginner"))
                 ,(resource-card
                   "Jaylib"
                   "https://github.com/janet-lang/jaylib"
                   "Janet bindings for Raylib. Make games with Janet!"
                   '("library" "free"))
                 ,(resource-card
                   "JPM"
                   "https://github.com/janet-lang/jpm"
                   "Janet Project Manager - package manager and build tool for Janet projects."
                   '("tool" "free")))))

;; Others section
(define (others-section)
  `(section (@ (id "others") (class "section dialect others"))
            (h2 (@ (class "section-title"))
                (span (@ (class "paren")) "(")
                "Other Lisps & Inspired Languages"
                (span (@ (class "paren")) ")"))
            (p (@ (class "section-intro"))
               "The Lisp family keeps growing. These languages bring Lisp ideas to new domains and platforms.")
            (div (@ (class "resources-grid"))
                 ,(resource-card
                   "Fennel"
                   "https://fennel-lang.org/"
                   "A Lisp that compiles to Lua. Perfect for game development with LÖVE2D."
                   '("language" "free"))
                 ,(resource-card
                   "Hy"
                   "https://hylang.org/"
                   "A Lisp embedded in Python. Access Python's ecosystem with Lisp syntax."
                   '("language" "free"))
                 ,(resource-card
                   "Picolisp"
                   "https://picolisp.com/"
                   "A radically minimalist Lisp focused on simplicity and expressiveness."
                   '("language" "free"))
                 ,(resource-card
                   "LFE (Lisp Flavoured Erlang)"
                   "https://lfe.io/"
                   "Lisp syntax for the Erlang VM. Distributed, fault-tolerant Lisp."
                   '("language" "free"))
                 ,(resource-card
                   "Carp"
                   "https://github.com/carp-lang/Carp"
                   "A statically typed Lisp without garbage collection for real-time systems."
                   '("language" "free"))
                 ,(resource-card
                   "uLisp"
                   "http://www.ulisp.com/"
                   "A Lisp for microcontrollers. Run Lisp on Arduino, ESP32, and other embedded devices."
                   '("language" "free"))
                 ,(resource-card
                   "Wisp"
                   "https://www.draketo.de/software/wisp"
                   "Lisp with optional indentation-based syntax. Python-like looks, Lisp semantics."
                   '("tool" "free"))
                 ,(resource-card
                   "Arc"
                   "http://arclanguage.org/"
                   "Paul Graham's experimental Lisp dialect focused on brevity."
                   '("language" "free"))
                 ,(resource-card
                   "Bel"
                   "http://www.paulgraham.com/bel.html"
                   "Paul Graham's latest Lisp specification - a spec for a new dialect."
                   '("language" "experimental"))
                 ,(resource-card
                   "JavaScript"
                   "https://brendaneich.com/2008/04/popularity/"
                   "\"Scheme in the browser\" they said. First-class functions, closures, and lambda... under a Java costume."
                   '("language" "free" "classic")))))

;; Main content export
(define (index-content)
  `(div (@ (class "content"))
        ,(hero-section)
        ,(repl-section)
        ,(history-section)
        ,(general-section)
        ,(common-lisp-section)
        ,(scheme-section)
        ,(racket-section)
        ,(clojure-section)
        ,(emacs-lisp-section)
        ,(janet-section)
        ,(others-section)))
