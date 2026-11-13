(in-package #:pea-soup)


;; +----------------------------------------+
;; |                        ##     #####   #|
;; |                      #####           ##|
;; |                      ##       ###     #|
;; |                ###   #         ##   ###|
;; |                 ##            #        |
;; |                          ##      ###   |
;; |                        ###      ##     |
;; |                          #        ##   |
;; |                              ###      #|
;; |                            #####     ##|
;; |                ##  #########       ####|
;; |                ##  #########  ###    ##|
;; |            ######  ##     ##  ###    ##|
;; |            ######  ##  #####  ###    ##|
;; |            ##          #####  ###    ##|
;; |            ##  ##   ######    #########|
;; |            ##  ##            ##########|
;; |       #######  ###########   ##########|
;; |       ###                              |
;; |       ###  ##########   ###############|
;; |  ########  ##########   ###############|
;; |  ########               #####          |
;; |            ###   ####    ####   #######|
;; |###############   ####    ####          |
;; |###############  e############          |
;; |         ###                      ######|
;; |         ###                ####  ######|
;; |    ###################     ####  ######|
;; |    ###################     ####  ####  |
;; |##########           #########          |
;; |##########      #####################   |
;; |            #########################   |
;; |  ###################################   |
;; |  #################     #############   |
;; |        ####          ####              |
;; |        ####          ####     ####     |
;; |           ######   ###        ####     |
;; |           ######   ###    ######    ###|
;; |                    ########        ####|
;; |##################            ##########|
;; +----------------------------------------+

(defconstant +MAP_SIZE+ 40)

(defun set-bit-arr-pos (arr-in x-in y-in)
  (setf (sbit arr-in y-in x-in)
        1)
)

(defun create-test-map-wall-data ()
  (let ((ret-arr (make-array (list +MAP_SIZE+ +MAP_SIZE+)
                             :element-type 'bit
                             :initial-element 0)))
    (set-bit-arr-pos ret-arr 24 0)
    (set-bit-arr-pos ret-arr 25 0)

    (set-bit-arr-pos ret-arr 31 0)
    (set-bit-arr-pos ret-arr 32 0)
    (set-bit-arr-pos ret-arr 33 0)
    (set-bit-arr-pos ret-arr 34 0)
    (set-bit-arr-pos ret-arr 35 0)

    (set-bit-arr-pos ret-arr 39 0)

    (set-bit-arr-pos ret-arr 22 1)
    (set-bit-arr-pos ret-arr 23 1)
    (set-bit-arr-pos ret-arr 24 1)
    (set-bit-arr-pos ret-arr 25 1)
    (set-bit-arr-pos ret-arr 26 1)

    (set-bit-arr-pos ret-arr 38 1)
    (set-bit-arr-pos ret-arr 39 1)

    (set-bit-arr-pos ret-arr 22 2)
    (set-bit-arr-pos ret-arr 23 2)

    (set-bit-arr-pos ret-arr 31 2)
    (set-bit-arr-pos ret-arr 32 2)
    (set-bit-arr-pos ret-arr 33 2)

    (set-bit-arr-pos ret-arr 39 2)

    (set-bit-arr-pos ret-arr 16 3)
    (set-bit-arr-pos ret-arr 17 3)
    (set-bit-arr-pos ret-arr 18 3)

    (set-bit-arr-pos ret-arr 22 3)

    (set-bit-arr-pos ret-arr 32 3)
    (set-bit-arr-pos ret-arr 33 3)

    (set-bit-arr-pos ret-arr 37 3)
    (set-bit-arr-pos ret-arr 38 3)
    (set-bit-arr-pos ret-arr 39 3)

    (set-bit-arr-pos ret-arr 17 4)
    (set-bit-arr-pos ret-arr 18 4)

    (set-bit-arr-pos ret-arr 31 4)

    (set-bit-arr-pos ret-arr 26 5)
    (set-bit-arr-pos ret-arr 27 5)

    (set-bit-arr-pos ret-arr 34 5)
    (set-bit-arr-pos ret-arr 35 5)
    (set-bit-arr-pos ret-arr 36 5)


    (set-bit-arr-pos ret-arr 24 6)
    (set-bit-arr-pos ret-arr 25 6)
    (set-bit-arr-pos ret-arr 26 6)

    (set-bit-arr-pos ret-arr 33 6)
    (set-bit-arr-pos ret-arr 34 6)

    (set-bit-arr-pos ret-arr 26 7)

    (set-bit-arr-pos ret-arr 35 7)
    (set-bit-arr-pos ret-arr 36 7)

    (set-bit-arr-pos ret-arr 30 8)
    (set-bit-arr-pos ret-arr 31 8)
    (set-bit-arr-pos ret-arr 32 8)

    (set-bit-arr-pos ret-arr 39 8)

    (set-bit-arr-pos ret-arr 28 9)
    (set-bit-arr-pos ret-arr 29 9)
    (set-bit-arr-pos ret-arr 30 9)
    (set-bit-arr-pos ret-arr 31 9)
    (set-bit-arr-pos ret-arr 32 9)

    (set-bit-arr-pos ret-arr 38 9)
    (set-bit-arr-pos ret-arr 39 9)

    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 16) 10))
    (dotimes (i 9)
      (set-bit-arr-pos ret-arr (+ i 20) 10))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 36) 10))

    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 16) 11))
    (dotimes (i 9)
      (set-bit-arr-pos ret-arr (+ i 20) 11))
    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 31) 11))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 38) 11))

    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 12) 12))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 20) 12))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 27) 12))
    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 31) 12))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 38) 12))

    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 12) 13))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 20) 13))
    (dotimes (i 5)
      (set-bit-arr-pos ret-arr (+ i 24) 13))
    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 31) 13))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 38) 13))

    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 12) 14))
    (dotimes (i 5)
      (set-bit-arr-pos ret-arr (+ i 24) 14))
    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 31) 14))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 38) 14))

    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 12) 15))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 16) 15))
    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 21) 15))
    (dotimes (i 9)
      (set-bit-arr-pos ret-arr (+ i 31) 15))

    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 12) 16))
    (dotimes (i 2)
      (set-bit-arr-pos ret-arr (+ i 16) 16))
    (dotimes (i 10)
      (set-bit-arr-pos ret-arr (+ i 30) 16))

    (dotimes (i 7)
      (set-bit-arr-pos ret-arr (+ i 7) 17))
    (dotimes (i 11)
      (set-bit-arr-pos ret-arr (+ i 16) 17))
    (dotimes (i 10)
      (set-bit-arr-pos ret-arr (+ i 30) 17))

    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 7) 18))

    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 7) 19))
    (dotimes (i 10)
      (set-bit-arr-pos ret-arr (+ i 12) 19))
    (dotimes (i 15)
      (set-bit-arr-pos ret-arr (+ i 25) 19))

    (dotimes (i 8)
      (set-bit-arr-pos ret-arr (+ i 2) 20))
    (dotimes (i 10)
      (set-bit-arr-pos ret-arr (+ i 12) 20))
    (dotimes (i 15)
      (set-bit-arr-pos ret-arr (+ i 25) 20))

    (dotimes (i 8)
      (set-bit-arr-pos ret-arr (+ i 2) 21))
    (dotimes (i 5)
      (set-bit-arr-pos ret-arr (+ i 25) 21))

    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 12) 22))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 18) 22))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 26) 22))
    (dotimes (i 7)
      (set-bit-arr-pos ret-arr (+ i 33) 22))

    (dotimes (i 15)
      (set-bit-arr-pos ret-arr (+ i 0) 23))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 18) 23))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 26) 23))

    (dotimes (i 15)
      (set-bit-arr-pos ret-arr (+ i 0) 24))
    (dotimes (i 12)
      (set-bit-arr-pos ret-arr (+ i 18) 24))

    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 9) 25))
    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 34) 25))

    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 9) 26))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 28) 26))
    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 34) 26))

    (dotimes (i 19)
      (set-bit-arr-pos ret-arr (+ i 4) 27))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 28) 27))
    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 34) 27))

    (dotimes (i 19)
      (set-bit-arr-pos ret-arr (+ i 4) 28))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 28) 28))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 34) 28))

    (dotimes (i 10)
      (set-bit-arr-pos ret-arr (+ i 0) 29))
    (dotimes (i 9)
      (set-bit-arr-pos ret-arr (+ i 21) 29))

    (dotimes (i 10)
      (set-bit-arr-pos ret-arr (+ i 0) 30))
    (dotimes (i 21)
      (set-bit-arr-pos ret-arr (+ i 16) 30))

    (dotimes (i 25)
      (set-bit-arr-pos ret-arr (+ i 12) 31))

    (dotimes (i 35)
      (set-bit-arr-pos ret-arr (+ i 2) 32))

    (dotimes (i 17)
      (set-bit-arr-pos ret-arr (+ i 2) 33))
    (dotimes (i 13)
      (set-bit-arr-pos ret-arr (+ i 24) 33))

    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 8) 34))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 22) 34))

    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 8) 35))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 22) 35))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 31) 35))

    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 11) 36))
    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 20) 36))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 31) 36))

    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 11) 37))
    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 20) 37))
    (dotimes (i 6)
      (set-bit-arr-pos ret-arr (+ i 27) 37))
    (dotimes (i 3)
      (set-bit-arr-pos ret-arr (+ i 37) 37))

    (dotimes (i 8)
      (set-bit-arr-pos ret-arr (+ i 20) 38))
    (dotimes (i 4)
      (set-bit-arr-pos ret-arr (+ i 36) 38))

    (dotimes (i 18)
      (set-bit-arr-pos ret-arr (+ i 0) 39))
    (dotimes (i 10)
      (set-bit-arr-pos ret-arr (+ i 30) 39))

    ;; (loop for row from 0 below (array-dimension ret-arr 0) do (progn
    ;;   (loop for col from 0 below (array-dimension ret-arr 1) do
    ;;     (format t (if (zerop (sbit ret-arr row col)) " " "#")))
    ;;   (format t "~%")))

    ret-arr)
)

;; `entity-poses` is a list of cons cells of `(<x> . <y>)`
;;   each pos cons cell must be inside of square grid of side length `+MAP_SIZE+`
(defun create-test-map-entity-data (entity-poses)
  (let ((ret-arr (make-array (list +MAP_SIZE+ +MAP_SIZE+)
                             :element-type 'fixnum
                             :initial-element 0)))
    (loop for cur-pos in entity-poses do
      (setf (aref ret-arr (cdr cur-pos) (car cur-pos))
            1))

    ;; (loop for row from 0 below (array-dimension ret-arr 0) do (progn
    ;;   (loop for col from 0 below (array-dimension ret-arr 1) do
    ;;     (format t (if (zerop (aref ret-arr row col)) " " "@")))
    ;;   (format t "~%")))

    ret-arr)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter +MAP_WALL_DATA+ (create-test-map-wall-data))
(defparameter +MAP_EMPTY_ENTITY_DATA+ (create-test-map-entity-data '()))

(test-eq "get-target-direction 1" :up
  (get-target-direction 6 7
                        0 0))

(test-eq "get-target-direction 2" :left
  (get-target-direction 6 5
                        0 0))

(test-eq "get-target-direction 3" :up
  (get-target-direction 6 6
                        0 0))

(test-eq "get-target-direction 4" :down
  (get-target-direction 0 0
                        6 7))

(test-eq "get-target-direction 5" :right
  (get-target-direction 0 0
                        10 7))

(test-eq "get-target-direction 6" nil
  (get-target-direction 0 0
                        21 7))

(test-eq "get-target-direction 7" :right
  (get-target-direction 0 0
                        20 7))

(test-eq "get-target-direction 8" :right
  (get-target-direction 0 0
                        20 10))

(test-eq "get-target-direction 9" nil
  (get-target-direction 0 0
                        20 11))

(test-eq "get-target-direction 10" nil
  (get-target-direction 0 0
                        20 20))

(test-eq "get-target-direction 11" nil
  (get-target-direction 0 0
                        30 7))

(test-eq "get-target-direction 12" :left
  (get-target-direction 0 0
                        -10 5))

(test-eq "get-target-direction 13" :left
  (get-target-direction 0 0
                        -10 9))

(test-eq "get-target-direction 14" :down
  (get-target-direction 0 0
                        -10 10))

(test-eq "get-target-direction 15" nil
  (get-target-direction 0 0
                        -18 11))

(test-eq "get-target-direction 16" :left
  (get-target-direction 0 0
                        -18 6))

(test-eq "get-target-direction 17" :down
  (get-target-direction 0 0
                        6 18))

(test-eq "get-target-direction 17" :up
  (get-target-direction 0 0
                        6 -18))

(test-eq "get-target-direction 18" :up
  (get-target-direction 0 0
                        6 -20))

(test-eq "get-target-direction 19" nil
  (get-target-direction 0 0
                        6 -21))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(test-equal "run-pathfind 1" '(t :left)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       7 10
                                       #(0 10)))))

(test-equal "run-pathfind 2" '(t :right)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       10 10
                                       #(12 10)))))

(test-equal "run-pathfind 3" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       10 10
                                       #(12 10)))))

(test-equal "run-pathfind 4" '(t :up)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       10 10
                                       #(12 7)))))

(test-equal "run-pathfind 5" '(t :up)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       10 7
                                       #(19 3)))))

(test-equal "run-pathfind 6" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       10 1
                                       #(19 3)))))

(test-equal "run-pathfind 7" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       16 4
                                       #(19 3)))))

(test-equal "run-pathfind 8" '(t :up)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       15 3
                                       #(19 3)))))

(test-equal "run-pathfind 9" '(t :right)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       24 4
                                       #(34 3)))))

(test-equal "run-pathfind 10" '(t :right)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       24 4
                                       #(29 10)))))

(test-equal "run-pathfind 11" '(t :right)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       24 4
                                       #(29 14)))))

(test-equal "run-pathfind 12" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       24 4
                                       #(29 15)))))

(test-equal "run-pathfind 13" '(t :right)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       24 4
                                       #(29 15)))))

(test-equal "run-pathfind 14" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       24 4
                                       #(17 24)))))

(test-equal "run-pathfind 15" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       24 4
                                       #(17 25)))))

(test-equal "run-pathfind 16" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       24 4
                                       #(10 21)))))

(test-equal "run-pathfind 17" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       24 4
                                       #(10 21)))))

(test-equal "run-pathfind 18" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       24 4
                                       #(10 21)))))

(test-equal "run-pathfind 19" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       39 21
                                       #(18 21)))))

(test-equal "run-pathfind 20" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       39 21
                                       #(19 21)))))

(test-equal "run-pathfind 21" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :up
                                       39 21
                                       #(19 21)))))

(test-equal "run-pathfind 22" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :up
                                       39 21
                                       #(22 22)))))

(test-equal "run-pathfind 23" '(t :left)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       24 21
                                       #(19 21)))))

(test-equal "run-pathfind 24" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       24 21
                                       #(22 20)))))

(test-equal "run-pathfind 25" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       5 26
                                       #(14 26)))))

(test-equal "run-pathfind 26" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :up
                                       5 26
                                       #(14 26)))))

(test-equal "run-pathfind 27" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       5 26
                                       #(14 26)))))

(test-equal "run-pathfind 28" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       5 26
                                       #(14 26)))))

(test-equal "run-pathfind 29" '(t :left)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       5 26
                                       #(0 28)))))

(test-equal "run-pathfind 30" '(t :left)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       5 26
                                       #(0 28)))))

(test-equal "run-pathfind 31" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :up
                                       5 26
                                       #(0 28)))))

(test-equal "run-pathfind 32" '(nil nil)
  (let ((map-entity-data (create-test-map-entity-data '((0 . 27)
                                                        (1 . 27)
                                                        (2 . 27)
                                                        (3 . 27)))))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       5 26
                                       #(0 28)))))

(test-equal "run-pathfind 33" '(t :left)
  (let ((map-entity-data (create-test-map-entity-data '((0 . 27)
                                                        (1 . 27)
                                                        ;; (2 . 27)
                                                        (3 . 27)))))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       5 26
                                       #(0 28)))))

(test-equal "run-pathfind 34" '(nil nil)
  (let ((map-entity-data (create-test-map-entity-data '((0 . 27)
                                                        (1 . 27)
                                                        (3 . 26)
                                                        (3 . 27)))))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :down
                                       5 26
                                       #(0 28)))))

(test-equal "run-pathfind 35" '(t :up)
  (let ((map-entity-data (create-test-map-entity-data '((0 . 27)
                                                        (1 . 27)
                                                        (3 . 26)
                                                        (3 . 27)))))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       5 26
                                       #(0 28)))))

(test-equal "run-pathfind 36" '(t :right)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       4 5
                                       #(19 13
                                         26 8
                                         20 4)))))

(test-equal "run-pathfind 37" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :right
                                       4 5
                                       #(23 3
                                         27 6
                                         9 12)))))

(test-equal "run-pathfind 38" '(t :up)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :up
                                       11 8
                                       #(22 8
                                         20 4
                                         4 5)))))

(test-equal "run-pathfind 39" '(t :up)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :left
                                       17 24
                                       #(4 25
                                         2 28
                                         4 16)))))

(test-equal "run-pathfind 40" '(t :right)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (run-pathfind +MAP_WALL_DATA+ map-entity-data :up
                                       17 21
                                       #(24 21
                                         11 19
                                         18 13)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(test-equal "get-next-run-direction-single-target 1" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           6 3
                           11 18))))

(test-equal "get-next-run-direction-single-target 2" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           6 3
                           16 18))))

(test-equal "get-next-run-direction-single-target 3" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           6 3
                           17 18))))

(test-equal "get-next-run-direction-single-target 4" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           6 3
                           19 14))))

(test-equal "get-next-run-direction-single-target 5" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           6 3
                           19 13))))

(test-equal "get-next-run-direction-single-target 6" '(t :right)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           6 3
                           26 8))))

(test-equal "get-next-run-direction-single-target 7" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           6 3
                           27 8))))

(test-equal "get-next-run-direction-single-target 8" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           30 18))))

(test-equal "get-next-run-direction-single-target 9" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           18 18))))

(test-equal "get-next-run-direction-single-target 10" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           10 22))))

(test-equal "get-next-run-direction-single-target 11" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           9 22))))

(test-equal "get-next-run-direction-single-target 12" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           18 11))))

(test-equal "get-next-run-direction-single-target 13" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           18 10))))

(test-equal "get-next-run-direction-single-target 14" '(nil nil)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           23 33))))

(test-equal "get-next-run-direction-single-target 15" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           26 34))))

(test-equal "get-next-run-direction-single-target 16" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           20 39))))

(test-equal "get-next-run-direction-single-target 17" '(t :down)
  (let ((map-entity-data +MAP_EMPTY_ENTITY_DATA+))
    (multiple-value-list (get-next-run-direction-single-target
                           +MAP_WALL_DATA+ map-entity-data
                           30 21
                           25 23))))
