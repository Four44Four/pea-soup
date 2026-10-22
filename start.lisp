(load "~/quicklisp/setup.lisp")
(push (uiop:pathname-directory-pathname *load-truename*)
      asdf:*central-registry*)

(ql:quickload :pea-soup)
(in-package :pea-soup)
(main)
