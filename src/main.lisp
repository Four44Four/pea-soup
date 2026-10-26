(in-package #:pea-soup)

;; adjust the CFFI shared library search paths to look in `./libs/`
(eval-when (:compile-toplevel :load-toplevel :execute)
  (let ((runtime-path
          #+sbcl sb-ext:*runtime-pathname*
          #+ccl ccl:*heap-image-name*
          #+ecl (si:argv 0)
          #-(or sbcl ccl ecl) nil))
    (when runtime-path
      (let ((bin-dir-path (uiop:pathname-directory-pathname runtime-path)))
        (pushnew (merge-pathnames "libs/" bin-dir-path)
                 cffi:*foreign-library-directories*
                 :test #'equal)))))

(defparameter +REFRESH_FPS+ 15)
(defparameter +REFRESH_DELTA_TIME+ (float (/ internal-time-units-per-second +REFRESH_FPS+)
                                     1.0f0))

(defparameter +BASE_DIR+ nil)

(defstruct async-timer
  repeat-p
  start-time
  delay-time
  callback-fn)

(defvar *active-async-timers* (make-hash-table :test #'equal))

(defparameter +LOG_FILE_PATH+ "logs/test.log")

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

(defmacro do-hash-table ((cur-key-sym-in cur-val-sym-in hash-table-in) &rest body-in)
  (let ((unint-next-fn (gensym))
        (unint-hash-table-in (gensym))
        (unint-ended-p (gensym))
        (has-declares (and (consp (car body-in))
                           (eq 'declare (caar body-in)))))
    `(let ((,unint-hash-table-in ,hash-table-in))
       (with-hash-table-iterator (,unint-next-fn ,unint-hash-table-in)
         (loop
           (multiple-value-bind (,unint-ended-p ,cur-key-sym-in ,cur-val-sym-in) (,unint-next-fn)
             ,@(when has-declares
                 (list (car body-in)))
             (unless ,unint-ended-p
               (return))
             ,@(if has-declares
                 (cdr body-in)
                 body-in))))))
)

(defun clamp (v-in min-in max-in)
  (max min-in (min v-in max-in))
)

(defun ensure-trailing-slash (str-in)
  (if (and (> (length str-in) 0)
           (char= (char str-in (1- (length str-in)))
                  #\/))
    str-in
    (concatenate 'string str-in "/"))
)

(defun init-base-dir ()
  (let ((appdir-in (uiop:getenv "APPDIR")))
    (setq +BASE_DIR+ (if appdir-in
                       ;; (merge-pathnames "/" appdir-in)
                       (ensure-trailing-slash appdir-in)
                       (uiop:getcwd))))
)

(cffi:defcfun ("setlocale" --setlocale) :string
  (category :int)
  (locale :string))

;; ---------------------------------------------------------------------------------------------------------

;; COLORS
(defconstant +NO_COLOR_ID+ -1)

(defconstant +YELLOW1_ID+ 10)
(defconstant +WALL_COLOR_PAIR_ID+ 1)
(defparameter +WALL_COLOR_PAIR+ nil)

(defconstant +GREEN1_ID+ 11)
(defconstant +PLAYER_COLOR_PAIR_ID+ 2)
(defparameter +PLAYER_COLOR_PAIR+ nil)

(defconstant +GREEN1_REDDISH_ID+ 13)
(defconstant +PLAYER_HURTING_COLOR_PAIR_ID+ 4)
(defconstant +GREEN1_GREENISH_ID+ 14)
(defparameter +PLAYER_HURTING_COLOR_PAIR+ nil)

(defconstant +PLAYER_HEALING_COLOR_PAIR_ID+ 5)
(defparameter +PLAYER_HEALING_COLOR_PAIR+ nil)

(defconstant +GREEN_DARK1_ID+ 12)
(defconstant +OTHERS_COLOR_PAIR_ID+ 3)
(defparameter +OTHERS_COLOR_PAIR+ nil)

(defconstant +GREEN_DARK1_REDDISH_ID+ 15)
(defconstant +OTHERS_HURTING_COLOR_PAIR_ID+ 6)
(defparameter +OTHERS_HURTING_COLOR_PAIR+ nil)

(defconstant +GREEN_DARK1_GREENISH_ID+ 16)
(defconstant +OTHERS_HEALING_COLOR_PAIR_ID+ 7)
(defparameter +OTHERS_HEALING_COLOR_PAIR+ nil)

(defun init-all-colors ()
  (charms/ll:start-color)
  (charms/ll:use-default-colors)

  (charms/ll:init-color +YELLOW1_ID+ 467 420 239)
  (charms/ll:init-pair +WALL_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +YELLOW1_ID+)
  (setq +WALL_COLOR_PAIR+ (charms/ll:color-pair +WALL_COLOR_PAIR_ID+))

  (charms/ll:init-color +GREEN1_ID+ 500 1000 250)
  (charms/ll:init-pair +PLAYER_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +GREEN1_ID+)
  (setq +PLAYER_COLOR_PAIR+ (charms/ll:color-pair +PLAYER_COLOR_PAIR_ID+))

  (charms/ll:init-color +GREEN_DARK1_ID+ 500 800 500)
  (charms/ll:init-pair +OTHERS_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +GREEN_DARK1_ID+)
  (setq +OTHERS_COLOR_PAIR+ (charms/ll:color-pair +OTHERS_COLOR_PAIR_ID+))

  (charms/ll:init-color +GREEN1_REDDISH_ID+ 710 835 235)
  (charms/ll:init-pair +PLAYER_HURTING_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +GREEN1_REDDISH_ID+)
  (setq +PLAYER_HURTING_COLOR_PAIR+ (charms/ll:color-pair +PLAYER_HURTING_COLOR_PAIR_ID+))

  (charms/ll:init-color +GREEN1_GREENISH_ID+ 0 1000 329)
  (charms/ll:init-pair +PLAYER_HEALING_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +GREEN1_GREENISH_ID+)
  (setq +PLAYER_HEALING_COLOR_PAIR+ (charms/ll:color-pair +PLAYER_HEALING_COLOR_PAIR_ID+))

  (charms/ll:init-color +GREEN_DARK1_REDDISH_ID+ 729 804 500)
  (charms/ll:init-pair +OTHERS_HURTING_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +GREEN_DARK1_REDDISH_ID+)
  (setq +OTHERS_HURTING_COLOR_PAIR+ (charms/ll:color-pair +OTHERS_HURTING_COLOR_PAIR_ID+))

  (charms/ll:init-color +GREEN_DARK1_GREENISH_ID+ 263 926 384)
  (charms/ll:init-pair +OTHERS_HEALING_COLOR_PAIR_ID+ charms/ll:COLOR_BLACK +GREEN_DARK1_GREENISH_ID+)
  (setq +OTHERS_HEALING_COLOR_PAIR+ (charms/ll:color-pair +OTHERS_HEALING_COLOR_PAIR_ID+))
)

;; ---------------------------------------------------------------------------------------------------------

;; AUDIO
(defconstant +NO_LOOP_AUDIO+ 0)
(defparameter +BOING_MP3_PATH_REL+ "resources/boing.mp3")
(defparameter +BOING_MP3+ nil)

(defmacro with-loaded-audio (&rest body-in)
  `(progn
     (sdl2-mixer:init :mp3)
     (sdl2-mixer:open-audio 44100 :s16sys 2 2048)
     (sdl2-mixer:allocate-channels 16)

     (setq +BOING_MP3+ (sdl2-mixer:load-wav (merge-pathnames +BOING_MP3_PATH_REL+ +BASE_DIR+)))

     ,@body-in

     (sdl2-mixer:free-chunk +BOING_MP3+)
     (sdl2-mixer:close-audio)
     (sdl2-mixer:quit))
)

;; ---------------------------------------------------------------------------------------------------------

(defparameter +MAP_WIDTH+ 400)
(defparameter +MAP_HEIGHT+ 400)
(defparameter +MAP_SPAWN_RADIUS+ 10)
(defparameter +OTHERS_SPAWN_MAX_INIT_RADIUS+ 5)
(defparameter +OTHERS_SPAWN_MAX_TRY_RADIUS+ 10)
(defparameter +ENTITIES_TICK_DELTA_TIME+ (* 1 internal-time-units-per-second))
(defparameter +ENTITY_NORMAL_ATK_DMG+ 10)
(defparameter +ENTITY_NORMAL_HEAL_AMT+ 10)
(defparameter +ENTITY_MAX_HEALTH+ 100)
(defparameter +ENTITY_NO_DMG_CHAR_CODE+ (char-code #\Space))
(defparameter +ENTITY_LIGHT_DMG_CHAR_CODE+ (char-code #\-))
(defparameter +ENTITY_MEDIUM_DMG_CHAR_CODE+ (char-code #\O))
(defparameter +ENTITY_HEAVY_DMG_CHAR_CODE+ (char-code #\@))
(defparameter +ENTITY_REGEN_AMT_PER_TICK+ 2)
(defparameter +ENTITIES_STATE_UPDATE_DURA_TIME+ (* 2 internal-time-units-per-second))

(deftype entity-state ()
  `(member :neutral :hurting :healing))

(defstruct entity
  id
  map-x
  map-y
  color-pair ;; can be `nil`
  hurting-color-pair
  healing-color-pair
  (state :neutral :type entity-state)
  (health +ENTITY_MAX_HEALTH+) ;; 0 to `+ENTITY_MAX_HEALTH+`
  (prev-map-x -1)
  (prev-map-y -1)
  (prev-display-wall-p nil)
)

(defstruct game-state
  map-wall-data ;; 2d array of bits (1 -> wall, 0 -> no-wall)
  map-entity-data ;; 2d array of integers (entity ids) (0 -> no-entity, >= 1 -> entity)
  ;; these represent the top left corner of the map as the "camera"
  (cur-x 0)
  (cur-y 0)
  (moved-p nil)
  (redraw-p nil)
  (player-entity nil) ;; can be `nil`
  (entities (make-hash-table :test #'eql))
  (cur-entity-id 0 :type (unsigned-byte 32)) ;; starts at 1+ this value
)

(deftype direction ()
  `(member :up :down :left :right))

;; ---------------------------------------------------------------------------------------------------------

(defun main ()
  (init-base-dir)
  ;; (print-to-log-file "~& .... ~A~%" +BASE_DIR+)

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
                     (game-state-instance (make-game-state :map-wall-data (generate-map-wall-data +MAP_WIDTH+ +MAP_HEIGHT+)
                                                           :map-entity-data (make-array (list +MAP_HEIGHT+ +MAP_WIDTH+)
                                                                                        :element-type '(unsigned-byte 32)
                                                                                        :initial-element 0)))
                     (first-frame-p t))

                ;; populate `map-pad` according to game state
                (loop for x from 0 below +MAP_WIDTH+ do
                  (loop for y from 0 below +MAP_HEIGHT+ do
                    (if (zerop (sbit (game-state-map-wall-data game-state-instance) y x))
                      (charms/ll:mvwaddch map-pad y x (char-code #\Space))
                      (progn
                        (charms/ll:wattron map-pad +WALL_COLOR_PAIR+)
                        (charms/ll:mvwaddch map-pad y x (char-code #\Space))
                        (charms/ll:wattroff map-pad +WALL_COLOR_PAIR+)))))

                (start-async-timer "entities tick"
                                   :delay-time +ENTITIES_TICK_DELTA_TIME+
                                   :callback-fn #'(lambda ()
                                                  (tick-all-entities map-pad game-state-instance))
                                   :repeat-p t)

                (sdl2:with-event-loop (:method :poll)
                  (:quit ()
                    t)
                  (:idle ()
                    (let* ((cur-time (get-internal-real-time))
                           (elapsed-time (- cur-time last-frame-time)))
                      (when (>= elapsed-time +REFRESH_DELTA_TIME+)
                        (setf last-frame-time cur-time)

                        (multiple-value-bind (cur-win-width cur-win-height)
                            (charms:window-dimensions main-window)
                          ;; TODO: can impl viewport resizing by just comparing prev and current `viewport-width` and `viewport-height`
                          (let ((viewport-width (1- cur-win-width))
                                (viewport-height (1- cur-win-height)))
                            ;; reset `moved-p` + `redraw-p`
                            (setf (game-state-moved-p game-state-instance) nil
                                  (game-state-redraw-p game-state-instance) nil)
                            (run-or-update-async-timers)

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
                (print-to-log-file "~%~A~%" error-in)
                #+sbcl
                  (print-to-log-file "~%~A~%" (with-output-to-string (strm-out)
                                                (sb-debug:backtrace :stream strm-out))))))))))
)

;; `get-next-char-fn` is a zero arg function that returns the next character in the input stream or `nil` if it has ended
(defun handle-input-chars (first-input-char-in get-next-char-fn game-state-in
                           max-cam-map-x max-cam-map-y
                           map-pad-in)
  (case first-input-char-in
    (#\Esc
      (let ((next-input-char-in (funcall get-next-char-fn)))
        (case next-input-char-in
          ;; check ALT keybind combinations
          (#\i
            (let ((player-entity (game-state-player-entity game-state-in)))
              (when player-entity
                (heal-entity game-state-in map-pad-in player-entity
                             :up))))
          (#\j
            (let ((player-entity (game-state-player-entity game-state-in)))
              (when player-entity
                (heal-entity game-state-in map-pad-in player-entity
                             :left))))
          (#\k
            (let ((player-entity (game-state-player-entity game-state-in)))
              (when player-entity
                (heal-entity game-state-in map-pad-in player-entity
                             :down))))
          (#\l
            (let ((player-entity (game-state-player-entity game-state-in)))
              (when player-entity
                (heal-entity game-state-in map-pad-in player-entity
                             :right))))
          (t
            ;; TODO: remove this one arrows are implemented
            ;; check if non-arrow key: exit
            (unless (and next-input-char-in (char= #\[ next-input-char-in))
              (sdl2:push-event :quit))))))
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
    (#\I
      (let ((player-entity (game-state-player-entity game-state-in)))
        (when player-entity
          (attack-entity game-state-in map-pad-in player-entity
                         :up))))
    (#\J
      (let ((player-entity (game-state-player-entity game-state-in)))
        (when player-entity
          (attack-entity game-state-in map-pad-in player-entity
                         :left))))
    (#\K
      (let ((player-entity (game-state-player-entity game-state-in)))
        (when player-entity
          (attack-entity game-state-in map-pad-in player-entity
                         :down))))
    (#\L
      (let ((player-entity (game-state-player-entity game-state-in)))
        (when player-entity
          (attack-entity game-state-in map-pad-in player-entity
                         :right))))
    (t nil))
)

(defun get-display-char-code-entity (entity-in)
  (let ((cur-health (entity-health entity-in)))
    (cond
      ((= cur-health +ENTITY_MAX_HEALTH+)
        +ENTITY_NO_DMG_CHAR_CODE+)
      ((>= cur-health 67)
        +ENTITY_LIGHT_DMG_CHAR_CODE+)
      ((>= cur-health 33)
        +ENTITY_MEDIUM_DMG_CHAR_CODE+)
      (t
        +ENTITY_HEAVY_DMG_CHAR_CODE+)))
)

;; updates `map-pad-in` and `game-state-in`
(defun set-map-cell (map-pad-in game-state-in
                     map-x map-y wall-p-bit)
  (setf (sbit (game-state-map-wall-data game-state-in)
              map-y map-x)
        wall-p-bit)

  (if (zerop wall-p-bit)
    (charms/ll:mvwaddch map-pad-in map-y map-x (char-code #\Space))
    (progn
      (charms/ll:wattron map-pad-in +WALL_COLOR_PAIR+)
      (charms/ll:mvwaddch map-pad-in map-y map-x (char-code #\Space))
      (charms/ll:wattroff map-pad-in +WALL_COLOR_PAIR+)))

  (mark-pad-dirty game-state-in map-pad-in map-x map-y)
)

(defun get-active-color-pair-entity (entity-in)
  (ecase (entity-state entity-in)
    (:neutral
      (entity-color-pair entity-in))
    (:hurting 
      (entity-hurting-color-pair entity-in))
    (:healing 
      (entity-healing-color-pair entity-in)))
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
      (mark-pad-dirty game-state-in map-pad-in prev-map-x prev-map-y)))

  (let ((cur-map-x (entity-map-x entity-in))
        (cur-map-y (entity-map-y entity-in)))
    ;; update other wall display information for `entity-in`
    (setf (entity-prev-display-wall-p entity-in)
          (= 1 (sbit (game-state-map-wall-data game-state-in)
                     cur-map-y cur-map-x)))

    ;; draw `entity-in` at new char cell
    (visual-update-entity game-state-in map-pad-in entity-in)
    ;; (let ((cur-entity-color-pair (get-active-color-pair-entity entity-in)))
    ;;   (when cur-entity-color-pair
    ;;     (charms/ll:wattron map-pad-in cur-entity-color-pair))
    ;;   (charms/ll:mvwaddch map-pad-in cur-map-y cur-map-x (get-display-char-code-entity entity-in))
    ;;   (when cur-entity-color-pair
    ;;     (charms/ll:wattroff map-pad-in cur-entity-color-pair))
    ;;   (mark-pad-dirty game-state-in map-pad-in cur-map-x cur-map-y))
    )
)

(defun visual-update-entity (game-state-in map-pad-in entity-in)
  (let ((cur-map-x (entity-map-x entity-in))
        (cur-map-y (entity-map-y entity-in))
        (cur-color-pair (get-active-color-pair-entity entity-in)))
    (if (zerop (entity-health entity-in))
      ;; dead: clear the spot
      (charms/ll:mvwaddch map-pad-in cur-map-y cur-map-x (char-code #\Space))
      ;; not dead: maybe update the display char
      (progn
        (when cur-color-pair
          (charms/ll:wattron map-pad-in cur-color-pair))
        (charms/ll:mvwaddch map-pad-in cur-map-y cur-map-x (get-display-char-code-entity entity-in))
        (when cur-color-pair
          (charms/ll:wattroff map-pad-in cur-color-pair))))
    (mark-pad-dirty game-state-in map-pad-in cur-map-x cur-map-y))
)

(defun mark-pad-dirty (game-state-in pad-in pad-x pad-y)
  (let ((dirty-screen-x (- pad-x (game-state-cur-x game-state-in)))
        (dirty-screen-y (- pad-y (game-state-cur-y game-state-in))))
    (charms/ll:pnoutrefresh pad-in
                            pad-y pad-x
                            dirty-screen-y dirty-screen-x
                            dirty-screen-y dirty-screen-x)
    (setf (game-state-redraw-p game-state-in)
          t))
)

;; returns a 2d bit array
(defun generate-map-wall-data (width-in height-in)
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
  (do-hash-table (cur-name cur-async-timer *active-async-timers*)
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
)

;; --------------------------------------------------------------------------------------------------------------------

(defun on-first-frame (map-pad-in game-state-in
                       viewport-width-in viewport-height-in)
  (let ((spawn-map-x (+ (game-state-cur-x game-state-in) (ash viewport-width-in -1)))
        (spawn-map-y (+ (game-state-cur-y game-state-in) (ash viewport-height-in -1))))

    (clear-spawn-area map-pad-in game-state-in spawn-map-x spawn-map-y)

    (spawn-player map-pad-in game-state-in spawn-map-x spawn-map-y)

    ;; spawn NPCs
    (dotimes (i 10)
      (let ((other-spawn-map-x (+ spawn-map-x (- (random (1+ (* 2 +OTHERS_SPAWN_MAX_INIT_RADIUS+))) +OTHERS_SPAWN_MAX_INIT_RADIUS+)))
            (other-spawn-map-y (+ spawn-map-y (- (random (1+ (* 2 +OTHERS_SPAWN_MAX_INIT_RADIUS+))) +OTHERS_SPAWN_MAX_INIT_RADIUS+))))
        (spawn-other-entity map-pad-in game-state-in
                            other-spawn-map-x other-spawn-map-y))))
)

;; creates a new entity and renders it on `map-pad-in` at `map-x-in` `map-y-in` with `color-pair-in`
;; returns the created entity instance
;;   modifies `game-state-in` as a side effect
(defun spawn-entity (map-pad-in game-state-in
                     map-x-in map-y-in
                     color-pair-in hurting-color-pair-in healing-color-pair-in)
  (incf (game-state-cur-entity-id game-state-in))
  (let* ((cur-entity-id (game-state-cur-entity-id game-state-in))
         (ret-entity (make-entity :id cur-entity-id
                                  :map-x map-x-in :map-y map-y-in
                                  :color-pair color-pair-in
                                  :hurting-color-pair hurting-color-pair-in
                                  :healing-color-pair healing-color-pair-in)))
    (setf (gethash cur-entity-id
                   (game-state-entities game-state-in))
          ret-entity)
    (setf (aref (game-state-map-entity-data game-state-in) map-y-in map-x-in)
          cur-entity-id)
    (visual-move-entity game-state-in map-pad-in ret-entity)
    ret-entity)
)

;; attempts to move `entity-in` to `new-map-x` `new-map-y`
;; returns non-`nil` if successfully moved `entity-in`
;;         or `nil` if `entity-in` remains at the same place due to cancelled movement
(defun move-entity (game-state-in map-pad-in
                     entity-in
                    new-map-x new-map-y)
  (unless (or (< new-map-x 0) (>= new-map-x +MAP_WIDTH+)
              (< new-map-y 0) (>= new-map-y +MAP_HEIGHT+)
              (= 1 (sbit (game-state-map-wall-data game-state-in)
                         new-map-y new-map-x))
              (/= 0 (aref (game-state-map-entity-data game-state-in)
                           new-map-y new-map-x)))
    (setf (entity-prev-map-x entity-in) (entity-map-x entity-in)
          (entity-prev-map-y entity-in) (entity-map-y entity-in)
          (aref (game-state-map-entity-data game-state-in) new-map-y new-map-x)
            (entity-id entity-in)
          (aref (game-state-map-entity-data game-state-in) (entity-map-y entity-in) (entity-map-x entity-in))
            0
          (entity-map-x entity-in) new-map-x
          (entity-map-y entity-in) new-map-y)


    (visual-move-entity game-state-in map-pad-in entity-in)

    t)
)

(defun maybe-remove-dead-entity (game-state-in entity-in)
  (let ((cur-health (entity-health entity-in)))
    (when (zerop cur-health)
      (setf (aref (game-state-map-entity-data game-state-in) (entity-map-y entity-in) (entity-map-x entity-in))
            0)
      (remhash (entity-id entity-in)
               (game-state-entities game-state-in))
      (when (eq entity-in (game-state-player-entity game-state-in))
        (setf (game-state-player-entity game-state-in)
              nil))))
)

(defun get-entity-id-in-direction (game-state-in direction-in src-map-x src-map-y)
  (declare (type direction direction-in))
  (let ((map-entity-data (game-state-map-entity-data game-state-in)))
    (ecase direction-in
      (:up
        (aref map-entity-data (1- src-map-y) src-map-x))
      (:down
        (aref map-entity-data (1+ src-map-y) src-map-x))
      (:left
        (aref map-entity-data src-map-y (1- src-map-x)))
      (:right
        (aref map-entity-data src-map-y (1+ src-map-x)))))
)

(defun update-state-entity (game-state-in map-pad-in entity-in entity-state-in)
  (declare (type entity-state entity-state-in))
  ;; if `entity-in` receives another entity-state update:
  ;;   overwrite the current reset-state timer task (we don't want it to reset it >1 times)
  (start-async-timer (concatenate 'string (princ-to-string (entity-id entity-in))
                                          "-reset-state")
                     :delay-time +ENTITIES_STATE_UPDATE_DURA_TIME+
                     :callback-fn #'(lambda ()
                                    (setf (entity-state entity-in)
                                          :neutral)
                                    (visual-update-entity game-state-in map-pad-in entity-in)))
  (setf (entity-state entity-in)
        entity-state-in)
  (visual-update-entity game-state-in map-pad-in entity-in)
)

;; TODO: maybe add  "shield" that can be activated to reduce dmg in the direction of previous movement 

;; deals `+ENTITY_NORMAL_ATK_DMG+` to whatever entity is in `direction-in` relative to `entity-in`
;; returns the attacked entity, or `nil`
;;   also updates `game-state-in` according to if the attack damaged or killed an entity
(defun attack-entity (game-state-in map-pad-in entity-in direction-in)
  (declare (type direction direction-in))
  (let ((target-entity-id 0)
        (src-map-x (entity-map-x entity-in))
        (src-map-y (entity-map-y entity-in)))
    (setq target-entity-id (get-entity-id-in-direction game-state-in direction-in src-map-x src-map-y))
    (unless (zerop target-entity-id)
      (let ((target-entity (gethash target-entity-id
                                    (game-state-entities game-state-in))))
        (decf (entity-health target-entity)
              +ENTITY_NORMAL_ATK_DMG+)
        (when (< (entity-health target-entity) 0)
          (setf (entity-health target-entity)
                0))
        (update-state-entity game-state-in map-pad-in target-entity :hurting)
        (maybe-remove-dead-entity game-state-in target-entity)
        target-entity)))
)

;; heals `+ENTITY_NORMAL_HEAL_AMT+` to whatever entity is in `direction-in` relative to `entity-in`
;; damages `entity-in` if successfully healed
;; returns the healed entity, or `nil`
;;   also updates `game-state-in` according to if the heal succeeded
(defun heal-entity (game-state-in map-pad-in entity-in direction-in)
  (declare (type direction direction-in))
  (let ((target-entity-id 0)
        (src-map-x (entity-map-x entity-in))
        (src-map-y (entity-map-y entity-in)))
    (setq target-entity-id (get-entity-id-in-direction game-state-in direction-in src-map-x src-map-y))
    (unless (zerop target-entity-id)
      (let* ((target-entity (gethash target-entity-id
                                     (game-state-entities game-state-in)))
             (og-target-health (entity-health target-entity)))
        (incf (entity-health target-entity)
              +ENTITY_NORMAL_HEAL_AMT+)
        (when (> (entity-health target-entity) +ENTITY_MAX_HEALTH+)
          (setf (entity-health target-entity)
                +ENTITY_MAX_HEALTH+))
        ;; damage `entity-in` for the amt healed
        (let ((healed-amt (- (entity-health target-entity) og-target-health)))
          (unless (zerop healed-amt)
            (decf (entity-health entity-in)
                  healed-amt)
            (visual-update-entity game-state-in map-pad-in entity-in)
            (maybe-remove-dead-entity game-state-in entity-in)))
        (update-state-entity game-state-in map-pad-in target-entity :healing)
        target-entity)))
)

(defun spawn-player (map-pad-in game-state-in
                     map-x-in map-y-in)
  (setf (game-state-player-entity game-state-in)
        (spawn-entity map-pad-in game-state-in
                      map-x-in
                      map-y-in
                      +PLAYER_COLOR_PAIR+ +PLAYER_HURTING_COLOR_PAIR+ +PLAYER_HEALING_COLOR_PAIR+))
)

(defun clear-spawn-area (map-pad-in game-state-in
                         map-x-in map-y-in)
  (loop for x from (- map-x-in +MAP_SPAWN_RADIUS+) below (+ map-x-in +MAP_SPAWN_RADIUS+) do
    (loop for y from (- map-y-in +MAP_SPAWN_RADIUS+) below (+ map-y-in +MAP_SPAWN_RADIUS+) do
      (set-map-cell map-pad-in game-state-in
                    x y 0)))
)

(defun spawn-other-entity (map-pad-in game-state-in
                           map-x-in map-y-in)
  (multiple-value-bind (spawn-map-x spawn-map-y) (get-next-available-pos game-state-in map-x-in map-y-in +OTHERS_SPAWN_MAX_TRY_RADIUS+)
    (when spawn-map-x
      (spawn-entity map-pad-in game-state-in
                    spawn-map-x
                    spawn-map-y
                    +OTHERS_COLOR_PAIR+ +OTHERS_HURTING_COLOR_PAIR+ +OTHERS_HEALING_COLOR_PAIR+)))
)

;; returns valid map-x and map-y
;;         or `nil` if none are found
;; `max-layers-in` must be >= 1
(defun get-next-available-pos (game-state-in map-x-in map-y-in max-layers-in)
  (let ((ret-map-x map-x-in)
        (ret-map-y map-y-in)
        (map-wall-data (game-state-map-wall-data game-state-in)))
    ;; only attempt searching if the original `map-x-in` and `map-y-in` are not valid
    (unless (zerop (sbit map-wall-data ret-map-y ret-map-x))
      ;; square search out 1 layer at a time
      ;;   return first valid position
      (loop named search-loop
            for layer-i from 1 below max-layers-in do
        (let ((start-x   (clamp (- map-x-in layer-i) 0 (1- +MAP_WIDTH+)))
              (end-x-inc (clamp (+ map-x-in layer-i) 0 (1- +MAP_WIDTH+)))
              (start-y   (clamp (- map-y-in layer-i) 0 (1- +MAP_HEIGHT+)))
              (end-y-inc (clamp (+ map-y-in layer-i) 0 (1- +MAP_HEIGHT+))))
          ;; top + bottom edges
          (loop for x from start-x to end-x-inc do
            (when (zerop (sbit map-wall-data start-y x))
              (setq ret-map-x x
                    ret-map-y start-y)
              (return-from search-loop))
            (when (zerop (sbit map-wall-data end-y-inc x))
              (setq ret-map-x x
                    ret-map-y end-y-inc)
              (return-from search-loop)))
          ;; left + right edges (excluding corners)
          (loop for y from (1+ start-y) below end-y-inc do
            (when (zerop (sbit map-wall-data y start-x))
              (setq ret-map-x start-x
                    ret-map-y y)
              (return-from search-loop))
            (when (zerop (sbit map-wall-data y end-x-inc))
              (setq ret-map-x end-x-inc
                    ret-map-y y)
              (return-from search-loop))))
        finally
          (progn
            (setq ret-map-x nil
                  ret-map-y nil)
            (return-from search-loop))))
    (values ret-map-x ret-map-y))
)

;; ------------------------------------------------------------------------------------------------------------

(defun tick-all-entities (map-pad-in game-state-in)
  (regen-all-entities map-pad-in game-state-in)
  (move-all-entities map-pad-in game-state-in)
)

(defun move-all-entities (map-pad-in game-state-in)
  (do-hash-table (cur-entity-id cur-entity (game-state-entities game-state-in))
    (declare (ignore cur-entity-id))
    (case (random 4)
      (0
        (move-entity game-state-in map-pad-in cur-entity
                     (1+ (entity-map-x cur-entity)) (entity-map-y cur-entity)))
      (1
        (move-entity game-state-in map-pad-in cur-entity
                     (1- (entity-map-x cur-entity)) (entity-map-y cur-entity)))
      (2
        (move-entity game-state-in map-pad-in cur-entity
                     (entity-map-x cur-entity) (1+ (entity-map-y cur-entity))))
      (3
        (move-entity game-state-in map-pad-in cur-entity
                     (entity-map-x cur-entity) (1- (entity-map-y cur-entity))))))
)

(defun regen-all-entities (map-pad-in game-state-in)
  (do-hash-table (cur-entity-id cur-entity (game-state-entities game-state-in))
    (declare (ignore cur-entity-id))
    (when (< (entity-health cur-entity) +ENTITY_MAX_HEALTH+)
      (incf (entity-health cur-entity)
            +ENTITY_REGEN_AMT_PER_TICK+)
      (when (> (entity-health cur-entity) +ENTITY_MAX_HEALTH+)
        (setf (entity-health cur-entity)
              +ENTITY_MAX_HEALTH+)))
    (visual-update-entity game-state-in map-pad-in cur-entity))
)
