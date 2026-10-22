(defsystem "pea-soup"
  :description "Experimental NCurses system-1 model game"
  :depends-on (:cl-charms)
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "main")))))
