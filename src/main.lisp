(in-package #:pea-soup)

(defparameter +REFRESH_FPS+ 15)
(defparameter +REFRESH_DELTA_TIME+ (float (/ internal-time-units-per-second +REFRESH_FPS+)
                                     1.0f0))
(defparameter +REFRESH_CONVERT_TO_SECS_MULT+ (float (/ 1 internal-time-units-per-second)
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

;; ---------------------------------------------------------------------------------------------------------

;; COLORS
(defconstant +NO_COLOR_ID+ -1)

(defconstant +GREEN1_ID+ 10)
(defconstant +GREEN1_BG_PAIR_ID+ 1)
(defparameter +GREEN1_BG_PAIR+ nil)

(defconstant +RED1_ID+ 11)
(defconstant +RED1_BG_PAIR_ID+ 2)
(defparameter +RED1_BG_PAIR+ nil)

(defconstant +ORANGE1_ID+ 12)
(defconstant +ORANGE1_FG_PAIR_ID+ 3)
(defparameter +ORANGE1_FG_PAIR+ nil)

(defun init-all-colors ()
  (charms/ll:start-color)
  (charms/ll:use-default-colors)

  (charms/ll:init-color +GREEN1_ID+   500  1000 250)
  (charms/ll:init-color +RED1_ID+     1000 250  250)
  (charms/ll:init-color +ORANGE1_ID+  1000 750  300)

  (charms/ll:init-pair +GREEN1_BG_PAIR_ID+  charms/ll:COLOR_BLACK +GREEN1_ID+)
  (charms/ll:init-pair +RED1_BG_PAIR_ID+    charms/ll:COLOR_BLACK +RED1_ID+)
  (charms/ll:init-pair +ORANGE1_FG_PAIR_ID+ +ORANGE1_ID+          +NO_COLOR_ID+)

  (setq +GREEN1_BG_PAIR+ (charms/ll:color-pair +GREEN1_BG_PAIR_ID+))
  (setq +RED1_BG_PAIR+ (charms/ll:color-pair +RED1_BG_PAIR_ID+))
  (setq +ORANGE1_FG_PAIR+ (charms/ll:color-pair +ORANGE1_FG_PAIR_ID+))
)

;; ---------------------------------------------------------------------------------------------------------

(defparameter +HELLO_WORLD_DELTA_TIME+ (* 5 internal-time-units-per-second))
(defparameter +TEMP_TEXT_DELAY_TIME+ (* 0.25 internal-time-units-per-second))

(defvar *show-temp-text-flag* nil)

(defun main ()
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
             (cur-text-flag t))

        (start-async-timer "hello world"
                           :delay-time +HELLO_WORLD_DELTA_TIME+
                           :callback-fn #'(lambda ()
                                          (setf cur-text-flag (not cur-text-flag)))
                           :repeat-p t)

        (loop named render-loop
              with exit-fn = #'(lambda () (return-from render-loop)) do
          (progn
            (let ((frame-start-time (get-internal-real-time)))
              ;; TODO: remove this when actually impling the map and camera
              ;;       use a Pad to render the entire map once, pan to move map
              ;;       and only redraw the entity movement character cells
              (charms:clear-window main-window)

              (run-or-update-async-timers)

              (multiple-value-bind (cur-win-width cur-win-height)
                  (charms:window-dimensions main-window)

                (let* ((cur-text (if cur-text-flag "Hello" "World !!"))
                       (cur-text-x (max 0 (floor (/ (- cur-win-width (length cur-text)) 2))))
                       (cur-text-y (max 0 (floor (/ cur-win-height 2)))))
                  
                  (if cur-text-flag
                    ;; make "Hello" orange
                    (charms/ll:wattron (charms::window-pointer main-window)
                                       +ORANGE1_FG_PAIR+)
                    ;; make "World !!" green
                    (charms/ll:wattron (charms::window-pointer main-window)
                                       +GREEN1_BG_PAIR+))
                  (charms:write-string-at-point main-window cur-text
                                                cur-text-x cur-text-y)
                  (if cur-text-flag
                    ;; reset the orange
                    (charms/ll:wattroff (charms::window-pointer main-window)
                                       +ORANGE1_FG_PAIR+)
                    ;; reset the green
                    (charms/ll:wattroff (charms::window-pointer main-window)
                                       +GREEN1_BG_PAIR+)))
                (when *show-temp-text-flag*
                  (let* ((cur-text "foobar")
                         (cur-text-x (max 0 (floor (/ (- cur-win-width (length cur-text)) 2))))
                         (cur-text-y (max 0 (1- (floor (/ cur-win-height 2))))))
                    (charms/ll:wattron (charms::window-pointer main-window)
                                       +RED1_BG_PAIR+)
                    (charms:write-string-at-point main-window cur-text
                                                  cur-text-x cur-text-y)
                    (charms/ll:wattroff (charms::window-pointer main-window)
                                       +RED1_BG_PAIR+))))

              (charms:refresh-window main-window)
              (handle-input-chars (funcall get-next-char-fn) get-next-char-fn exit-fn)

              (let* ((frame-end-time (get-internal-real-time))
                     (frame-elapsed-time (- frame-end-time frame-start-time))
                     (frame-sleep-time (- +REFRESH_DELTA_TIME+ frame-elapsed-time)))
                (sleep (* frame-sleep-time +REFRESH_CONVERT_TO_SECS_MULT+)))))))
      (error (error-in)
        (print-to-log-file "~%~A~%" error-in))))
)

;; `get-next-char-fn` is a zero arg function that returns the next character in the input stream or `nil` if it has ended
(defun handle-input-chars (first-input-char-in get-next-char-fn exit-fn-in)
  (case first-input-char-in
    ;; exit if `ESC` key is pressed
    (#\Esc
      ;; check if **not** arrow key
      (let ((next-input-char-in (funcall get-next-char-fn)))
        ;; (if (and next-input-char-in (char= #\[ next-input-char-in))
        ;;   (case (funcall get-next-char-fn)
        ;;     (#\A (print-to-log-file "~&Arrow key pressed: Up~%"))
        ;;     (#\B (print-to-log-file "~&Arrow key pressed: Down~%"))
        ;;     (#\C (print-to-log-file "~&Arrow key pressed: Right~%"))
        ;;     (#\D (print-to-log-file "~&Arrow key pressed: Left~%")))
        ;;   (funcall exit-fn-in))
        (unless (and next-input-char-in (char= #\[ next-input-char-in))
          ;; (print-to-log-file "~& >> ~A~%" (hash-table-count *active-async-timers*))
          (funcall exit-fn-in))
        ))
    (#\Space
      (setf *show-temp-text-flag* t)
      (start-async-timer "temp text"
                         :delay-time +TEMP_TEXT_DELAY_TIME+
                         :callback-fn #'(lambda ()
                                        (setf *show-temp-text-flag* nil))))
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
