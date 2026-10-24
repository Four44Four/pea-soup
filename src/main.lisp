(in-package #:pea-soup)

(defparameter +REFRESH_FPS+ 15)
(defparameter +REFRESH_DELTA_TIME+ (float (/ internal-time-units-per-second +REFRESH_FPS+)
                                     1.0f0))

(defstruct async-timer
  repeat-p
  start-time
  delay-time
  callback-fn)

(defvar *active-async-timers* (make-hash-table :test #'equal))

(defparameter +LOG_FILE_PATH+ "./logs/test.log")

(defmacro print-to-log-file (format-str-in &rest format-args-in)
  `(progn
    (ensure-directories-exist +LOG_FILE_PATH+)
    (with-open-file (file-strm +LOG_FILE_PATH+
                               :direction :output
                               :if-exists :append
                               :if-does-not-exist :create)
      (format file-strm ,format-str-in ,@format-args-in)
      (finish-output file-strm)))
)

(defun clamp (v-in min-in max-in)
  (max min-in (min v-in max-in))
)

(cffi:defcfun ("setlocale" --setlocale) :string
  (category :int)
  (locale :string))

;; ---------------------------------------------------------------------------------------------------------

;; COLORS
(defconstant +NO_COLOR_ID+ -1)

(defconstant +BROWN1_ID+ 10)
(defconstant +WALL_COLOR_PAIR_ID+ 1)
(defparameter +WALL_COLOR_PAIR+ nil)

(defconstant +GREEN1_ID+ 11)
(defconstant +PLAYER_COLOR_PAIR_ID+ 2)
(defparameter +PLAYER_COLOR_PAIR+ nil)

(defun init-all-colors ()
  (charms/ll:start-color)
  (charms/ll:use-default-colors)

  (charms/ll:init-color +BROWN1_ID+ 647 165 165)
  (charms/ll:init-pair +WALL_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +BROWN1_ID+)
  (setq +WALL_COLOR_PAIR+ (charms/ll:color-pair +WALL_COLOR_PAIR_ID+))

  (charms/ll:init-color +GREEN1_ID+ 500 1000 250)
  (charms/ll:init-pair +PLAYER_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +GREEN1_ID+)
  (setq +PLAYER_COLOR_PAIR+ (charms/ll:color-pair +PLAYER_COLOR_PAIR_ID+))
)

;; ---------------------------------------------------------------------------------------------------------

;; AUDIO
(defconstant +NO_LOOP_AUDIO+ 0)
(defparameter +BOING_MP3_PATH+ "resources/boing.mp3")
(defparameter +BOING_MP3+ nil)

(defmacro with-loaded-audio (&rest body-in)
  `(progn
     (sdl2-mixer:init :mp3)
     (sdl2-mixer:open-audio 44100 :s16sys 2 2048)
     (sdl2-mixer:allocate-channels 16)

     (setq +BOING_MP3+ (sdl2-mixer:load-wav +BOING_MP3_PATH+))

     ,@body-in

     (sdl2-mixer:free-chunk +BOING_MP3+)
     (sdl2-mixer:close-audio)
     (sdl2-mixer:quit))
)

;; ---------------------------------------------------------------------------------------------------------

(defparameter +MAP_WIDTH+ 400)
(defparameter +MAP_HEIGHT+ 400)

(defstruct entity
  id
  map-x
  map-y
  display-char-code
  color-pair ;; can be `nil`
  (prev-map-x -1)
  (prev-map-y -1)
  (prev-display-wall-p nil)
)

(defstruct game-state
  map-data ;; 2d array of bits (1 -> wall, 0 -> no-wall)
  ;; these represent the top left corner of the map as the "camera"
  (cur-x 0)
  (cur-y 0)
  (moved-p nil)
  (redraw-p nil)
  (player-entity nil) ;; can be `nil`
  (entities (make-hash-table :test #'eql))
  (cur-entity-id 0)
)

(defun main ()
  (sdl2:make-this-thread-main
    #'(lambda ()
      (sdl2:with-init (:audio :timer)
        (with-loaded-audio
          (--setlocale 6 "")
          (charms:with-curses ()
            (charms/ll:curs-set 0)
            (charms:disable-echoing)
            (charms:enable-raw-input :interpret-control-characters t)
            (charms:enable-non-blocking-mode charms:*standard-window*)

            (init-all-colors)

            (handler-case
              (let* ((main-window charms:*standard-window*)
                     ;; (main-window-ptr (charms::window-pointer main-window))
                     (get-next-char-fn #'(lambda ()
                                         (charms:get-char main-window :ignore-error t)))
                     (last-frame-time (get-internal-real-time))
                     (map-pad (charms/ll:newpad +MAP_WIDTH+ +MAP_HEIGHT+))
                     (game-state-instance (make-game-state :map-data (generate-map-data +MAP_WIDTH+ +MAP_HEIGHT+)))
                     (first-frame-p t))

                ;; populate `map-pad` according to game state
                (loop for x from 0 below +MAP_WIDTH+ do
                  (loop for y from 0 below +MAP_HEIGHT+ do
                    (if (= 1 (sbit (game-state-map-data game-state-instance) y x))
                      (progn
                        (charms/ll:wattron map-pad +WALL_COLOR_PAIR+)
                        (charms/ll:mvwaddch map-pad y x (char-code #\Space))
                        (charms/ll:wattroff map-pad +WALL_COLOR_PAIR+))
                      (charms/ll:mvwaddch map-pad y x (char-code #\Space)))))

                (sdl2:with-event-loop (:method :poll)
                  (:quit ()
                    t)
                  (:idle ()
                    (let* ((cur-time (get-internal-real-time))
                           (elapsed-time (- cur-time last-frame-time)))
                      (when (>= elapsed-time +REFRESH_DELTA_TIME+)
                        (setf last-frame-time cur-time)
                        (run-or-update-async-timers)

                        (multiple-value-bind (cur-win-width cur-win-height)
                            (charms:window-dimensions main-window)
                          (let ((viewport-width (1- cur-win-width))
                                (viewport-height (1- cur-win-height)))
                            ;; reset `moved-p` + `redraw-p`
                            (setf (game-state-moved-p game-state-instance) nil
                                  (game-state-redraw-p game-state-instance) nil)
                            ;; drain queued input
                            (loop for cur-char = (funcall get-next-char-fn)
                                  while cur-char do
                                    (handle-input-chars cur-char get-next-char-fn game-state-instance
                                                        (1- (- +MAP_WIDTH+ viewport-width))
                                                        (1- (- +MAP_HEIGHT+ viewport-height))
                                                        map-pad))
                            ;; do main rendering
                            (let ((cam-map-x (game-state-cur-x game-state-instance))
                                  (cam-map-y (game-state-cur-y game-state-instance)))
                              (when (or first-frame-p (game-state-moved-p game-state-instance))
                                (when first-frame-p
                                  (setf first-frame-p nil)
                                  (on-first-frame map-pad game-state-instance viewport-width viewport-height))
                                ;; redraw entire pad
                                (charms/ll:pnoutrefresh map-pad
                                                        cam-map-y cam-map-x
                                                        0 0
                                                        viewport-height viewport-width)
                                (setf (game-state-redraw-p game-state-instance)
                                      t))
                              (when (game-state-redraw-p game-state-instance)
                                (charms/ll:doupdate))))))
                      (sdl2:delay 1)))))
              (error (error-in)
                (print-to-log-file "~%~A~%" error-in))))))))
)

(defun on-first-frame (map-pad-in game-state-in
                       viewport-width-in viewport-height-in)
  (setf (game-state-player-entity game-state-in)
        (spawn-entity map-pad-in
                      game-state-in

                      (+ (game-state-cur-x game-state-in) (ash viewport-width-in -1))
                      (+ (game-state-cur-y game-state-in) (ash viewport-height-in -1))
                      (char-code #\Space)
                      +PLAYER_COLOR_PAIR+))
)

;; `get-next-char-fn` is a zero arg function that returns the next character in the input stream or `nil` if it has ended
(defun handle-input-chars (first-input-char-in get-next-char-fn game-state-in
                           max-cam-map-x max-cam-map-y
                           map-pad-in)
  (case first-input-char-in
    ;; exit if `ESC` key is pressed
    (#\Esc
      ;; check if **not** arrow key
      (let ((next-input-char-in (funcall get-next-char-fn)))
        (unless (and next-input-char-in (char= #\[ next-input-char-in))
          (sdl2:push-event :quit))))
    (#\Space
      (sdl2-mixer:play-channel -1 +BOING_MP3+ +NO_LOOP_AUDIO+))
    (#\w
      (setf (game-state-moved-p game-state-in)
            t)
      (setf (game-state-cur-y game-state-in)
            (clamp (1- (game-state-cur-y game-state-in))
                   0
                   max-cam-map-y)))
    (#\a
      (setf (game-state-moved-p game-state-in)
            t)
      (setf (game-state-cur-x game-state-in)
            (clamp (1- (game-state-cur-x game-state-in))
                   0
                   max-cam-map-x)))
    (#\s
      (setf (game-state-moved-p game-state-in)
            t)
      (setf (game-state-cur-y game-state-in)
            (clamp (1+ (game-state-cur-y game-state-in))
                   0
                   max-cam-map-y)))
    (#\d
      (setf (game-state-moved-p game-state-in)
            t)
      (setf (game-state-cur-x game-state-in)
            (clamp (1+ (game-state-cur-x game-state-in))
                   0
                   max-cam-map-x)))
    (#\i
      (let ((player-entity (game-state-player-entity game-state-in)))
        (when player-entity
          (move-entity game-state-in map-pad-in player-entity
                       (entity-map-x player-entity) (1- (entity-map-y player-entity))))))
    (#\j
      (let ((player-entity (game-state-player-entity game-state-in)))
        (when player-entity
          (move-entity game-state-in map-pad-in player-entity
                       (1- (entity-map-x player-entity))  (entity-map-y player-entity)))))
    (#\k
      (let ((player-entity (game-state-player-entity game-state-in)))
        (when player-entity
          (move-entity game-state-in map-pad-in player-entity
                       (entity-map-x player-entity) (1+ (entity-map-y player-entity))))))
    (#\l
      (let ((player-entity (game-state-player-entity game-state-in)))
        (when player-entity
          (move-entity game-state-in map-pad-in player-entity
                       (1+ (entity-map-x player-entity)) (entity-map-y player-entity)))))
    (t nil))
)

;; creates a new entity and renders it on `map-pad-in` at `map-x-in` `map-y-in` with `display-char-code-in` `color-pair-in`
;; returns the created entity instance
;;   modifies `game-state-in` as a side effect
(defun spawn-entity (map-pad-in game-state-in
                     map-x-in map-y-in display-char-code-in color-pair-in)
  (incf (game-state-cur-entity-id game-state-in))
  (let* ((cur-entity-id (game-state-cur-entity-id game-state-in))
         (ret-entity (make-entity :id cur-entity-id
                                  :map-x map-x-in :map-y map-y-in
                                  :display-char-code display-char-code-in :color-pair color-pair-in)))
    (setf (gethash cur-entity-id
                   (game-state-entities game-state-in))
          ret-entity)
    (visual-move-entity game-state-in map-pad-in ret-entity)
    ret-entity)
)

;; attempts to move `entity-in` to `new-map-x` `new-map-y`
;; returns non-`nil` if successfully moved `entity-in`
;;         or `nil` if `entity-in` remains at the same place due to cancelled movement
;; `new-map-x` and `new-map-y` are `map-data-in` relative
(defun move-entity (game-state-in map-pad-in ;map-data-in
                     entity-in
                    new-map-x new-map-y)
  ;; TODO: also make it not be able to intersect with other entities
  (unless (or (< new-map-x 0) (>= new-map-x +MAP_WIDTH+)
              (< new-map-y 0) (>= new-map-y +MAP_HEIGHT+)
              (= 1 (sbit (game-state-map-data game-state-in)
                         new-map-y new-map-x)))
    (setf (entity-prev-map-x entity-in) (entity-map-x entity-in)
          (entity-prev-map-y entity-in) (entity-map-y entity-in)
          (entity-map-x entity-in) new-map-x
          (entity-map-y entity-in) new-map-y)

    (visual-move-entity game-state-in map-pad-in entity-in)

    t)
)

;; should be called whenever `entity-in` moves on `map-pad-in`
(defun visual-move-entity (game-state-in map-pad-in entity-in)
  ;; erase `entity-in` at prev map cells
  (let ((prev-map-x (entity-prev-map-x entity-in))
        (prev-map-y (entity-prev-map-y entity-in)))
    (unless (or (< prev-map-x 0) (>= prev-map-x +MAP_WIDTH+)
                (< prev-map-y 0) (>= prev-map-y +MAP_HEIGHT+))
      (if (entity-prev-display-wall-p entity-in)
        (progn
          (charms/ll:wattron map-pad-in +WALL_COLOR_PAIR+)
          (charms/ll:mvwaddch map-pad-in prev-map-y prev-map-x (char-code #\Space))
          (charms/ll:wattroff map-pad-in +WALL_COLOR_PAIR+))
        (charms/ll:mvwaddch map-pad-in prev-map-y prev-map-x (char-code #\Space)))
      (let ((dirty-screen-x (- prev-map-x (game-state-cur-x game-state-in)))
            (dirty-screen-y (- prev-map-y (game-state-cur-y game-state-in))))
        (charms/ll:pnoutrefresh map-pad-in
                                prev-map-y prev-map-x
                                dirty-screen-y dirty-screen-x
                                dirty-screen-y dirty-screen-x))
      (setf (game-state-redraw-p game-state-in)
            t)))

  (let ((cur-map-x (entity-map-x entity-in))
        (cur-map-y (entity-map-y entity-in)))
      ;; update other wall display information for `entity-in`
      (setf (entity-prev-display-wall-p entity-in)
            (= 1 (sbit (game-state-map-data game-state-in)
                       cur-map-y cur-map-x)))

      ;; draw `entity-in` at new char cell
      (let ((cur-entity-color-pair (entity-color-pair entity-in))
            (cur-entity-display-char-code (entity-display-char-code entity-in)))
        (when cur-entity-color-pair
          (charms/ll:wattron map-pad-in cur-entity-color-pair))
        (charms/ll:mvwaddch map-pad-in cur-map-y cur-map-x cur-entity-display-char-code)
        (when cur-entity-color-pair
          (charms/ll:wattroff map-pad-in cur-entity-color-pair))
        (let ((dirty-screen-x (- cur-map-x (game-state-cur-x game-state-in)))
              (dirty-screen-y (- cur-map-y (game-state-cur-y game-state-in))))
          (charms/ll:pnoutrefresh map-pad-in
                                  cur-map-y cur-map-x
                                  dirty-screen-y dirty-screen-x
                                  dirty-screen-y dirty-screen-x))
        (setf (game-state-redraw-p game-state-in)
            t)));)
)

;; returns a 2d bit array
(defun generate-map-data (width-in height-in)
  (let ((ret-arr (make-array (list height-in width-in)
                             :element-type 'bit
                             :initial-element 0)))
    (loop for x from 0 below width-in do
      (loop for y from 0 below height-in do
        (when (zerop (random (1+ x)))
          (setf (sbit ret-arr y x)
                1))))
    ret-arr)
)

;; `name` is the unique identifying name this timer task is assigned
;;        if second async timer task is started with this same name, it immediately cancels/replaces the original async timer task
;; `delay-time` should be in the same units as `internal-time-units-per-second`
;; `callback-fn` is a function with no args
;; `repeat-p` should `callback-fn` repeat or not every `delay-time`
(defun start-async-timer (name-in &key delay-time callback-fn repeat-p)
  (setf (gethash name-in *active-async-timers*)
        (make-async-timer :start-time (get-internal-real-time)
                          :delay-time delay-time
                          :callback-fn callback-fn
                          :repeat-p repeat-p))
)

;; destructive to `*active-async-timers*`
(defun run-or-update-async-timers ()
  (maphash #'(lambda (cur-name cur-async-timer)
             (let ((cur-time (get-internal-real-time)))
               ;; is `cur-async-timer` expired ?
               (when (>= (- cur-time (async-timer-start-time cur-async-timer))
                         (async-timer-delay-time cur-async-timer))
                 (funcall (async-timer-callback-fn cur-async-timer))
                 (if (async-timer-repeat-p cur-async-timer)
                   ;; update start time + don't delete timer
                   (setf (async-timer-start-time cur-async-timer)
                         cur-time)
                   ;; delete timer
                   (remhash cur-name *active-async-timers*)))))
    *active-async-timers*)
)
