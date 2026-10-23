(defsystem "pea-soup"
  :description "Experimental NCurses system-1 model game"
  :depends-on (:cl-charms :sdl2 :sdl2-mixer)
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "main")))))
