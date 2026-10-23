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
  (charms/ll:init-pair +WALL_COLOR_PAIR_ID+ +BROWN1_ID+ charms/ll:COLOR_BLACK)
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

(defstruct game-state
  cur-x
  cur-y)

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
                     (get-next-char-fn #'(lambda ()
                                         (charms:get-char main-window :ignore-error t)))
                     (last-frame-time (get-internal-real-time))
                     (map-pad (charms/ll:newpad +MAP_WIDTH+ +MAP_HEIGHT+))
                     (game-state-instance (make-game-state :cur-x 0 :cur-y 0))
                     (moved-p-ref (make-array 1 :element-type 'bit :initial-element 0))
                     (first-frame-p t))
                ;; `moved-p-ref` on stack
                (declare (type (simple-array bit (1)) moved-p-ref)
                         (dynamic-extent moved-p-ref))

                ;; populate the map with walls
                (loop for x from 0 below +MAP_WIDTH+ do
                  (loop for y from 0 below +MAP_HEIGHT+ do
                    (if (or (zerop x) (zerop y)
                            (= x (1- +MAP_WIDTH+)) (= y (1- +MAP_HEIGHT+)))
                      (charms/ll:mvwaddch map-pad y x
                                          (char-code #\@))
                      (if (zerop (random x))
                        (charms/ll:mvwaddstr map-pad y x "█")
                        (charms/ll:mvwaddch map-pad y x
                                            (char-code #\Space))))))

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
                            ;; reset `moved-p-ref`
                            (setf (aref moved-p-ref 0)
                                  0)
                            (loop for cur-char = (funcall get-next-char-fn)
                                  while cur-char do
                                    (handle-input-chars cur-char get-next-char-fn game-state-instance
                                                        (1- (- +MAP_WIDTH+ viewport-width))
                                                        (1- (- +MAP_HEIGHT+ viewport-height))
                                                        moved-p-ref))
                            (when (or first-frame-p (= 1 (aref moved-p-ref 0)))
                              (setf first-frame-p nil)
                              (charms/ll:pnoutrefresh map-pad
                                                      (game-state-cur-y game-state-instance)
                                                      (game-state-cur-x game-state-instance)
                                                      0 0
                                                      viewport-height viewport-width)
                              (charms/ll:doupdate))
                            ;; (charms:refresh-window main-window)
                            )))
                      (sdl2:delay 1)))))
              (error (error-in)
                (print-to-log-file "~%~A~%" error-in))))))))
)

;; `get-next-char-fn` is a zero arg function that returns the next character in the input stream or `nil` if it has ended
(defun handle-input-chars (first-input-char-in get-next-char-fn game-state-in
                           max-pos-x max-pos-y
                           moved-p-ref)
  (declare (type (simple-array bit (1)) moved-p-ref))
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
      (setf (aref moved-p-ref 0)
            1)
      (setf (game-state-cur-y game-state-in)
            (clamp (1- (game-state-cur-y game-state-in))
                   0
                   max-pos-y)))
    (#\a
      (setf (aref moved-p-ref 0)
            1)
      (setf (game-state-cur-x game-state-in)
            (clamp (1- (game-state-cur-x game-state-in))
                   0
                   max-pos-x)))
    (#\s
      (setf (aref moved-p-ref 0)
            1)
      (setf (game-state-cur-y game-state-in)
            (clamp (1+ (game-state-cur-y game-state-in))
                   0
                   max-pos-y)))
    (#\d
      (setf (aref moved-p-ref 0)
            1)
      (setf (game-state-cur-x game-state-in)
            (clamp (1+ (game-state-cur-x game-state-in))
                   0
                   max-pos-x)))
    (t nil))
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
