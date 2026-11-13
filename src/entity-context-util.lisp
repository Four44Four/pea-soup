(in-package #:pea-soup)

(defparameter +LOOK_RANGE+ 21) ;; should be an odd number
(defparameter +LOOK_HALF_RANGE+ (truncate +LOOK_RANGE+ 2))
(defparameter +LOOK_AREA+ (* +LOOK_RANGE+ +LOOK_RANGE+))

;; <pathfind-id (29 bits) | side bit (1 bit) | forward-direction (2 bits)>
;;   pathfind-id -> `*cur-pathfind-id*` for this visited-state-arr index
;;   side bit -> which side is this visited-state-arr index (0 -> forward, 1 -> backward)
;;   forward-direction -> which direction for the forward node here (0 -> up, 1 -> down, 2 -> west, 3 -> east)
(defparameter *pathfind-visited-state-arr* (make-array +LOOK_AREA+  :element-type '(unsigned-byte 32) :initial-element 0))
(defparameter *cur-pathfind-id* 0)
(defparameter +PATHFIND_ID_MAX_VAL+ #x1FFFFFFF)
(defparameter +PATHFIND_ID_MASK+ #xFFFFFFF8)

(defparameter *pathfind-forward-queue* (make-array +LOOK_AREA+ :element-type 'fixnum))
(defparameter *pathfind-backward-queue* (make-array +LOOK_AREA+ :element-type 'fixnum))

;; can return a `direction` or `nil` if outside of `+LOOK_RANGE+`
;; prioritizes `:right` and `:left`
(defun get-target-direction (src-x src-y target-x target-y)
  (let* ((x-delta (- target-x src-x))
         (y-delta (- target-y src-y))
         (x-abs-delta (abs x-delta))
         (y-abs-delta (abs y-delta))
         (max-forward (1- +LOOK_RANGE+))
         (min-sideways (- +LOOK_HALF_RANGE+))
         (max-sideways (- max-forward +LOOK_HALF_RANGE+)))
    (if (> x-abs-delta y-abs-delta)
      ;; horizontal (check if `y-delta` is inclusively between `min-sideways` and `max-sideways`)
      (when (and (<= x-abs-delta max-forward)
                 (<= min-sideways y-delta max-sideways))
        (if (plusp x-delta)
          :right
          :left))
      ;; vertical (check if `x-delta` is inclusively between `min-sideways` and `max-sideways`)
      (when (and (<= y-abs-delta max-forward)
                 (<= min-sideways x-delta max-sideways))
        (if (plusp y-delta)
          :down
          :up))))
)

;; returns `(values <boolean-if-the-target-is-reachable>
;;                  <:up-:down-:left-:right-nil>)`
(defun get-next-run-direction-single-target (map-wall-data map-entity-data src-x src-y target-x target-y)
  ;; run a pathfind on whichever rectangle `target-x` `target-y` belongs in (`:up`, `:down`, `:left`, `:right`)
  (let ((target-direction (get-target-direction src-x src-y target-x target-y)))
    (if target-direction
      (run-pathfind map-wall-data
                    map-entity-data
                    target-direction
                    src-x src-y
                    (make-array 2 :element-type 'fixnum :initial-contents
                      (list target-x target-y)))
      (values nil nil)))
)

;; runs pathfinding for a single direction of square `+LOOK_RANGE+`
;; `map-wall-data` is a rectangular 2d array of bits (0 => floor, 1 => wall)
;; `map-entity-data` is a rectangular 2d array of `'(unsigned-byte 32)` of the same dimentions as `map-wall-data`
;; `target-poses-arr` is an array of target coordinates `#(<x1> <y1> <x2> <y2> <...>)`
;;   must be even number of elements
;; returns `(values <boolean-if-any-target-is-reachable>
;;                  <:up-:down-:left-:right-nil>)`
(defun run-pathfind (map-wall-data
                     map-entity-data
                     direction-in
                     src-x src-y
                     target-poses-arr)
  (declare (type direction direction-in))

  ;; check if invalid `target-poses-arr` format
  (when (oddp (length target-poses-arr))
    (error "`target-poses-arr` must have an even number of elements"))


  (let* ((rect-start-x (ecase direction-in
                         ((:up :down) (- src-x +LOOK_HALF_RANGE+))
                         (:left (- src-x (1- +LOOK_RANGE+)))
                         (:right src-x)))
         (rect-start-y (ecase direction-in
                         (:up (- src-y (1- +LOOK_RANGE+)))
                         (:down src-y)
                         ((:left :right) (- src-y +LOOK_HALF_RANGE+))))
         (map-height (array-dimension map-wall-data 0))
         (map-width (array-dimension map-wall-data 1))
         (src-x (max 0 (- src-x rect-start-x)))
         (src-y (max 0 (- src-y rect-start-y)))
         (min-local-x (max 0 (- rect-start-x)))
         (max-local-x (min +LOOK_RANGE+ (- map-width rect-start-x)))
         (min-local-y (max 0 (- rect-start-y)))
         (max-local-y (min +LOOK_RANGE+ (- map-height rect-start-y))))
    ;; short-circuit if entire search rect is outside of `map-wall-data` bounds
    ;;   (no searchable area)
    (when (or (>= min-local-x max-local-x)
              (>= min-local-y max-local-y)
              (< src-x min-local-x)
              (>= src-x max-local-x)
              (< src-y min-local-y)
              (>= src-y max-local-y))
      (return-from run-pathfind
                   (values nil nil)))

    (incf *cur-pathfind-id*)

    ;; wrap around when all 29 bits for pathfind-id are set
    (when (= +PATHFIND_ID_MAX_VAL+ *cur-pathfind-id*)
      (fill *pathfind-visited-state-arr* 0)
      (setq *cur-pathfind-id* 1))

    (let* ((pathfind-prefix (ash *cur-pathfind-id* 3))
           (f-tag pathfind-prefix)
           (b-tag (logior pathfind-prefix 4))
           (f-head 0)
           (b-head 0)
           (f-tail 0)
           (b-tail 0)
           (src-visited-state-index (+ (* src-y +LOOK_RANGE+) src-x)))
      ;; seed forward (from src-*)
      (setf (aref *pathfind-visited-state-arr* src-visited-state-index) f-tag
            (aref *pathfind-forward-queue* f-tail) src-visited-state-index)
      (incf f-tail)

      ;; seed backward (from targets-*)
      (loop for i from 0 below (1- (length target-poses-arr)) by 2
            for cur-target-x = (- (aref target-poses-arr i) rect-start-x)
            for cur-target-y = (- (aref target-poses-arr (1+ i)) rect-start-y)
            do
        (when (and (<= min-local-x cur-target-x)
                   (< cur-target-x max-local-x)
                   (<= min-local-y cur-target-y)
                   (< cur-target-y max-local-y)
                   (let ((cur-target-global-x (+ rect-start-x cur-target-x))
                         (cur-target-global-y (+ rect-start-y cur-target-y)))
                     (and (zerop (sbit map-wall-data cur-target-global-y cur-target-global-x))
                          (zerop (aref map-entity-data cur-target-global-y cur-target-global-x)))))
          (let ((cur-target-visited-state-index (+ (* cur-target-y +LOOK_RANGE+) cur-target-x)))
            (when (= cur-target-visited-state-index src-visited-state-index)
              (return-from run-pathfind
                           (values t nil)))
            (setf (aref *pathfind-visited-state-arr* cur-target-visited-state-index) b-tag
                  (aref *pathfind-backward-queue* b-tail) cur-target-visited-state-index)
            (incf b-tail))))

      (macrolet ((expand-step (queue-in head-in tail-in forward-p)
                  `(let* ((cur-visited-state-index (aref ,queue-in ,head-in))
                          ,@(when forward-p
                              `((cur-visited-state (aref *pathfind-visited-state-arr* cur-visited-state-index))
                                (src-p (= cur-visited-state-index src-visited-state-index))
                                (inherited-direction (logand cur-visited-state 3))))
                          (cur-x (mod cur-visited-state-index +LOOK_RANGE+))
                          (cur-y (truncate cur-visited-state-index +LOOK_RANGE+)))
                     (incf ,head-in)
                     (loop for cur-direction from 0 to 3
                           for neighbor-x = (+ cur-x (ecase cur-direction
                                                       (0 0)
                                                       (1 0)
                                                       (2 -1)
                                                       (3 1)))
                           for neighbor-y = (+ cur-y (ecase cur-direction
                                                       (0 -1)
                                                       (1 1)
                                                       (2 0)
                                                       (3 0)))
                           when (and (<= min-local-x neighbor-x)
                                     (< neighbor-x max-local-x)
                                     (<= min-local-y neighbor-y)
                                     (< neighbor-y max-local-y)
                                     (let ((neighbor-global-x (+ rect-start-x neighbor-x))
                                           (neighbor-global-y (+ rect-start-y neighbor-y)))
                                       (and (zerop (sbit map-wall-data neighbor-global-y neighbor-global-x))
                                            (zerop (aref map-entity-data neighbor-global-y neighbor-global-x)))))
                           do
                       (let* ((next-visited-state-index (+ (* neighbor-y +LOOK_RANGE+) neighbor-x))
                              (next-visited-state (aref *pathfind-visited-state-arr* next-visited-state-index)))
                         (cond
                           ;; if the pathfind-id bits don't match `pathfind-prefix`: handle non-visited
                           ((/= (logand next-visited-state +PATHFIND_ID_MASK+)
                                pathfind-prefix)
                             (setf (aref *pathfind-visited-state-arr* next-visited-state-index)
                                     ,(if forward-p
                                        `(logior f-tag (if src-p cur-direction inherited-direction))
                                        `b-tag)
                                   (aref ,queue-in ,tail-in)
                                     next-visited-state-index)
                             (incf ,tail-in))
                           ;; 
                           ((/= (logand next-visited-state 4)
                                ,(if forward-p 0 4))
                             (let ((first-direction ,(if forward-p
                                                       `(if src-p cur-direction inherited-direction)
                                                       `(if (= next-visited-state-index src-visited-state-index)
                                                          (ecase cur-direction
                                                            (0 1)
                                                            (1 0)
                                                            (2 3)
                                                            (3 2))
                                                          (logand next-visited-state 3)))))
                               (return-from run-pathfind
                                            (values t
                                                    (ecase first-direction
                                                      (0 :up)
                                                      (1 :down)
                                                      (2 :left)
                                                      (3 :right))))))))))))
        (loop while (and (< f-head f-tail)
                         (< b-head b-tail))
          do (if (<= (- f-tail f-head)
                     (- b-tail b-head))
               (expand-step *pathfind-forward-queue* f-head f-tail t)
               (expand-step *pathfind-backward-queue* b-head b-tail nil)))))

    (values nil nil))
)
