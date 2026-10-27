(in-package #:pea-soup)

(defstruct async-timer
  name
  repeat-p
  start-time
  delay-time
  callback-fn
)

;; compare based on current next expiration timestamp
(defun less-p-async-timer (async-timer-a async-timer-b)
  (< (+ (async-timer-start-time async-timer-a)
        (async-timer-delay-time async-timer-a))
     (+ (async-timer-start-time async-timer-b)
        (async-timer-delay-time async-timer-b)))
)

(defun get-key-async-timer (async-timer-in)
  (async-timer-name async-timer-in)
)

(impl-keyed-min-heap "timer-" async-timer
                     :less-p-fn-name less-p-async-timer
                     :extract-key-fn-name get-key-async-timer
                     :key-hash-eql-fn #'equal)

(defvar *active-async-timers* (make-timer-keyed-min-heap))

;; `name` is the unique identifying name this timer task is assigned
;;        if second async timer task is started with this same name, it immediately cancels/replaces the original async timer task
;; `delay-time` should be in the same units as `internal-time-units-per-second`
;; `callback-fn` is a function with no args
;; `repeat-p` should `callback-fn` repeat or not every `delay-time`
(defun start-async-timer (name-in &key delay-time callback-fn repeat-p)
  (upsert-timer-keyed-min-heap *active-async-timers*
                               (make-async-timer :name name-in
                                                 :start-time (get-internal-real-time)
                                                 :delay-time delay-time
                                                 :callback-fn callback-fn
                                                 :repeat-p repeat-p))
)

;; destructive to `*active-async-timers*`
(defun run-or-update-async-timers ()
  (loop with cur-time = (get-internal-real-time)
        with cur-min-timer = (peek-timer-keyed-min-heap *active-async-timers*)
        while (and cur-min-timer
                   (>= (- cur-time (async-timer-start-time cur-min-timer))
                       (async-timer-delay-time cur-min-timer)))
        do
    (progn
      (funcall (async-timer-callback-fn cur-min-timer))
      (if (async-timer-repeat-p cur-min-timer)
        ;; update start time + move timer to correct place in heap
        (progn
          (setf (async-timer-start-time cur-min-timer)
                cur-time)
          (heapify-timer-keyed-min-heap *active-async-timers* 0))
        ;; delete timer
        (pop-timer-keyed-min-heap *active-async-timers*))
      (setf cur-min-timer (peek-timer-keyed-min-heap *active-async-timers*))))
)
