(in-package #:pea-soup)

(defvar *failed-test-names* '())

(defun test-eq (test-name-in test-val-expected test-val-actual)
  (unless (eq test-val-expected test-val-actual)
    (format t "~&~A: [31mFAILED[0m, Actually: ~A~%" test-name-in test-val-actual)
    (push test-name-in *failed-test-names*))
)

(defun test-eql (test-name-in test-val-expected test-val-actual)
  (unless (eql test-val-expected test-val-actual)
    (format t "~&~A: [31mFAILED[0m, Actually: ~A~%" test-name-in test-val-actual)
    (push test-name-in *failed-test-names*))
)

(defun test-equal (test-name-in test-val-expected test-val-actual)
  (unless (equal test-val-expected test-val-actual)
    (format t "~&~A: [31mFAILED[0m, Actually: ~A~%" test-name-in test-val-actual)
    (push test-name-in *failed-test-names*))
)
