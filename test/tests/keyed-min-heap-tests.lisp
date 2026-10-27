(in-package #:pea-soup)

(defstruct foo
  (id-str "" :type string)
  (bar 0 :type (signed-byte 32))
  (buz "" :type string)
)

(defun less-p-foo (foo-a foo-b)
  (< (foo-bar foo-a) (foo-bar foo-b))
)

(defun get-key-foo (foo-in)
  (foo-id-str foo-in)
)

(impl-keyed-min-heap "" foo
                     :less-p-fn-name less-p-foo
                     :extract-key-fn-name get-key-foo
                     :key-hash-eql-fn #'equal)

(let ((my-heap (make-keyed-min-heap)))

(test-eql "size-pre-upsert(unique)" 0
  (size-keyed-min-heap my-heap))

(test-equal "upserts (unique)" '("mall" "kitchen" "according" "pulp" "quartic" "bagging" "bongo")
  (let ((ret-list '()))
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "tomato"
                               :bar 28
                               :buz "bongo")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "honking"
                               :bar 0
                               :buz "bagging")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "burps"
                               :bar 9
                               :buz "quartic")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "blasters"
                               :bar -18
                               :buz "pulp")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "flat"
                               :bar 8
                               :buz "according")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "burning"
                               :bar 7
                               :buz "kitchen")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "going"
                               :bar 89
                               :buz "mall")))
          ret-list)
    ret-list))

(test-eql "size-post-insert" 7
  (size-keyed-min-heap my-heap))

(test-equal "peek(unique)" "pulp"
  (foo-buz (peek-keyed-min-heap my-heap)))

(test-equal "pop-all(unique)" '(nil nil "mall" "bongo" "quartic" "according" "kitchen" "bagging" "pulp")
  (let ((ret-list '()))
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    ;; should be empty
    (push (pop-keyed-min-heap my-heap)
          ret-list)
    (push (pop-keyed-min-heap my-heap)
          ret-list)
    ret-list))

(test-eql "size-post-pop-all" 0
  (size-keyed-min-heap my-heap))

(test-equal "peek(non-unique)" nil
  (peek-keyed-min-heap my-heap))

(test-equal "upserts (non-unique)" '("periscope" "coming" "fishy" "blogger"
                                     "mall" "kitchen" "according" "pulp" "quartic" "bagging" "bongo")
  (let ((ret-list '()))
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "tomato"
                               :bar 28
                               :buz "bongo")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "honking"
                               :bar 0
                               :buz "bagging")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "burps"
                               :bar 9
                               :buz "quartic")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "blasters"
                               :bar -18
                               :buz "pulp")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "flat"
                               :bar 8
                               :buz "according")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "burning"
                               :bar 7
                               :buz "kitchen")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "going"
                               :bar 89
                               :buz "mall")))
          ret-list)


    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "honking"
                               :bar 67
                               :buz "blogger")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "flat"
                               :bar 90
                               :buz "fishy")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "boring"
                               :bar 78
                               :buz "coming")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "blasters"
                               :bar -199
                               :buz "periscope")))
          ret-list)
    ret-list))

(test-eql "size-post-upsert(non-unique)" 8
  (size-keyed-min-heap my-heap))

(test-equal "pop-all(non-unique)" '(nil nil "fishy" "mall" "coming" "blogger" "bongo" "quartic" "kitchen" "periscope")
  (let ((ret-list '()))
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    ;; should be empty
    (push (pop-keyed-min-heap my-heap)
          ret-list)
    (push (pop-keyed-min-heap my-heap)
          ret-list)
    ret-list))

(test-eql "size-post-pop-all(non-unique)" 0
  (size-keyed-min-heap my-heap))

(test-equal "upserts (non-unique) (2)" '("periscope" "coming" "fishy" "blogger"
                                         "mall" "kitchen" "according" "pulp" "quartic" "bagging" "bongo")
  (let ((ret-list '()))
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "tomato"
                               :bar 28
                               :buz "bongo")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "honking"
                               :bar 0
                               :buz "bagging")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "burps"
                               :bar 9
                               :buz "quartic")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "blasters"
                               :bar -18
                               :buz "pulp")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "flat"
                               :bar 8
                               :buz "according")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "burning"
                               :bar 7
                               :buz "kitchen")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "going"
                               :bar 89
                               :buz "mall")))
          ret-list)


    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "honking"
                               :bar 67
                               :buz "blogger")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "flat"
                               :bar 90
                               :buz "fishy")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "boring"
                               :bar 78
                               :buz "coming")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "blasters"
                               :bar -199
                               :buz "periscope")))
          ret-list)
    ret-list))

(test-eql "size-post-upsert(non-unique) (2)" 8
  (size-keyed-min-heap my-heap))

(test-equal "remove (non-unique) (2)" '("quartic" nil "fishy" "blogger")
  (let ((ret-list '()))
    (push (foo-buz (remove-keyed-min-heap my-heap "honking"))
          ret-list)
    (push (foo-buz (remove-keyed-min-heap my-heap "flat"))
          ret-list)
    ;; invalid key
    (push (remove-keyed-min-heap my-heap "ummmmm")
          ret-list)
    (push (foo-buz (remove-keyed-min-heap my-heap "burps"))
          ret-list)
    ret-list))

(test-eql "size-post-remove(non-unique) (2)" 5
  (size-keyed-min-heap my-heap))

(test-equal "peek(non-unique) (2)" "periscope"
  (foo-buz (peek-keyed-min-heap my-heap)))

(test-equal "pop-all(non-unique) (2)" '(nil "mall" "coming" "bongo""kitchen" "periscope")
  (let ((ret-list '()))
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    ;; should be empty
    (push (pop-keyed-min-heap my-heap)
          ret-list)
    ret-list))

(test-eql "size-post-pop-all(non-unique) (2)" 0
  (size-keyed-min-heap my-heap))

(test-equal "upserts (non-unique) (3)" '("periscope" "coming" "fishy" "blogger"
                                         "mall" "kitchen" "according" "pulp" "quartic" "bagging" "bongo")
  (let ((ret-list '()))
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "tomato"
                               :bar 28
                               :buz "bongo")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "honking"
                               :bar 0
                               :buz "bagging")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "burps"
                               :bar 9
                               :buz "quartic")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "blasters"
                               :bar -18
                               :buz "pulp")))
          ret-list)
    ;; replaced
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "flat"
                               :bar 8
                               :buz "according")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "burning"
                               :bar 7
                               :buz "kitchen")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "going"
                               :bar 89
                               :buz "mall")))
          ret-list)


    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "honking"
                               :bar 67
                               :buz "blogger")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "flat"
                               :bar 90
                               :buz "fishy")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "boring"
                               :bar 78
                               :buz "coming")))
          ret-list)
    (push (foo-buz (upsert-keyed-min-heap my-heap
                     (make-foo :id-str "blasters"
                               :bar -199
                               :buz "periscope")))
          ret-list)
    ret-list))

(test-eql "size-post-upsert(non-unique) (3)" 8
  (size-keyed-min-heap my-heap))

(test-equal "modify-peek-element heapify-sift-up pop-all" '(nil "periscope" "fishy" "mall" "coming" "blogger" "kitchen" "bongo" "quartic")
  (let ((ret-list '()))
    (setf (foo-bar (peek-keyed-min-heap my-heap))
          999999999)
    (heapify-keyed-min-heap my-heap 0)

    (setf (foo-bar (peek-keyed-min-heap my-heap))
          50)
    (heapify-keyed-min-heap my-heap 0)

    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)
    (push (foo-buz (pop-keyed-min-heap my-heap))
          ret-list)

    (push (pop-keyed-min-heap my-heap)
          ret-list)

    ret-list))

(test-eql "size-post-pop-all(non-unique) (3)" 0
  (size-keyed-min-heap my-heap))

)
