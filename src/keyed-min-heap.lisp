(in-package #:pea-soup)

;; `symbol-prefix-str` is the prefix that should be prepended to `keyed-min-heap*` functions
;;   can be left as `""` to refer to all keyed-min-heap functions by their bare names
;;   should end in a `-` if using a custom function prefix
;; `element-type-in` is a type keyword symbol (do not start it with a `'`)
;; `less-p-fn-name` is a predicate function that takes in 2 instances of `element-type-in` to determine the order that each element is sorted by in the min-heap (by default is `<`) (canNOT start with `'` or `#'`)
;; `extract-key-fn-name` returns the key to use as a hash-table key given a single arg of type `element-type-in` (canNOT start with `'` or `#'`)
;; `key-hash-eql-fn` is a predicate function for comparing hash-table keys (returned by `extract-key-fn-name`) (must start with `'` or `#'`)
(defmacro impl-keyed-min-heap (symbol-prefix-str element-type-in
                               &key (less-p-fn-name '<) extract-key-fn-name (key-hash-eql-fn #'eql))
(flet ((sym-name (base-name-str &key prefix-str)
         (intern (concatenate 'string (string-upcase (or prefix-str symbol-prefix-str)) base-name-str)))
       (sym-name-action (action-name-str base-name-str)
         (intern (concatenate 'string action-name-str (string-upcase symbol-prefix-str) base-name-str))))
(let ((keyed-min-heap-struct (sym-name "KEYED-MIN-HEAP"))
      (keyed-min-heap-struct-data (sym-name "KEYED-MIN-HEAP-DATA"))
      (keyed-min-heap-struct-index-map (sym-name "KEYED-MIN-HEAP-INDEX-MAP"))
      (--index-keyed-min-heap (sym-name "--INDEX-KEYED-MIN-HEAP"))
      (--insert-keyed-min-heap (sym-name "--INSERT-KEYED-MIN-HEAP"))
      (heapify-keyed-min-heap (sym-name-action "HEAPIFY-" "KEYED-MIN-HEAP"))
      (size-keyed-min-heap (sym-name-action "SIZE-" "KEYED-MIN-HEAP"))
      (pop-keyed-min-heap (sym-name-action "POP-" "KEYED-MIN-HEAP"))
      (remove-keyed-min-heap (sym-name-action "REMOVE-" "KEYED-MIN-HEAP"))
      (upsert-keyed-min-heap (sym-name-action "UPSERT-" "KEYED-MIN-HEAP"))
      (peek-keyed-min-heap (sym-name-action "PEEK-" "KEYED-MIN-HEAP")))
`(progn

(defstruct ,keyed-min-heap-struct
  (data (make-array 16 :element-type ',element-type-in
                       :adjustable t
                       :fill-pointer 0)
        :type (vector ,element-type-in))
  (index-map (make-hash-table :test ,key-hash-eql-fn)
        :type hash-table)
)


(defmacro ,--index-keyed-min-heap (keyed-min-heap-in element-in)
  `(gethash (,',extract-key-fn-name ,element-in)
            (,',keyed-min-heap-struct-index-map ,keyed-min-heap-in))
)

(defun ,heapify-keyed-min-heap (keyed-min-heap-in start-i)
  (let* ((data-arr (,keyed-min-heap-struct-data keyed-min-heap-in))
         (index-map (,keyed-min-heap-struct-index-map keyed-min-heap-in))
         (size (fill-pointer data-arr))
         (start-val (aref data-arr start-i))
         (i start-i))
    ;; heapify up
    (loop while (> i 0) do
      (let* ((parent-i (ash (1- i) -1))
             (parent-val (aref data-arr parent-i)))
        (if (,less-p-fn-name start-val parent-val)
          (progn
            (setf (aref data-arr i)
                  parent-val)
            (setf (gethash (,extract-key-fn-name parent-val) index-map)
                  i)
            (setf i parent-i))
          (return))))
    ;; heapify down (if heapify up didnt find anything to move)
    (when (= i start-i)
      (loop
        (let* ((left-i (1+ (ash i 1)))
               (right-i (1+ left-i))
               (smaller-i i))
          (when (and (< left-i size)
                     (,less-p-fn-name (aref data-arr left-i)
                                      (if (= smaller-i i)
                                        start-val
                                        (aref data-arr smaller-i))))
            (setf smaller-i left-i))
          (when (and (< right-i size)
                     (,less-p-fn-name (aref data-arr right-i)
                                      (if (= smaller-i i)
                                        start-val
                                        (aref data-arr smaller-i))))
            (setf smaller-i right-i))
          (if (/= smaller-i i)
            (let ((smaller-val (aref data-arr smaller-i)))
              (setf (aref data-arr i) smaller-val)
              (setf (gethash (,extract-key-fn-name smaller-val) index-map)
                    i)
              (setf i smaller-i))
            (return)))))
    (setf (aref data-arr i) start-val)
    (setf (gethash (,extract-key-fn-name start-val) index-map)
          i)
    t)
)

(declaim (inline ,size-keyed-min-heap))
(defun ,size-keyed-min-heap (keyed-min-heap-in)
  (fill-pointer (,keyed-min-heap-struct-data keyed-min-heap-in))
)

;; must only be called if `element-in` is garanteed to not collide with any elements already in `keyed-min-heap-in`
(defun ,--insert-keyed-min-heap (keyed-min-heap-in element-in)
  (let* ((data-arr (,keyed-min-heap-struct-data keyed-min-heap-in))
         (i (fill-pointer data-arr)))
    (vector-push-extend element-in data-arr)
    (setf (,--index-keyed-min-heap keyed-min-heap-in element-in)
          i)
    (,heapify-keyed-min-heap keyed-min-heap-in i))
)

;; removes the minimum value from `keyed-min-heap-in`
;; returns the minimum value from `min-heap-in` or `nil` if `keyed-min-heap-in` was empty
(defun ,pop-keyed-min-heap (keyed-min-heap-in)
  (let* ((data-arr (,keyed-min-heap-struct-data keyed-min-heap-in))
         (index-map (,keyed-min-heap-struct-index-map keyed-min-heap-in)))
    (unless (zerop (,size-keyed-min-heap keyed-min-heap-in))
      (let* ((ret-element (aref data-arr 0))
             (last-i (1- (fill-pointer data-arr)))
             (last-val (aref data-arr last-i)))
        (decf (fill-pointer data-arr))
        (remhash (,extract-key-fn-name ret-element) index-map)
        (unless (zerop (fill-pointer data-arr))
          (setf (aref data-arr 0) last-val)
          (setf (gethash (,extract-key-fn-name last-val) index-map)
                0)
          (,heapify-keyed-min-heap keyed-min-heap-in 0))
        ret-element)))
)

;; removes element with `key-in` from `keyed-min-heap-in`
;; returns removed element or `nil` if not found
(defun ,remove-keyed-min-heap (keyed-min-heap-in key-in)
  (let* ((data-arr (,keyed-min-heap-struct-data keyed-min-heap-in))
         (index-map (,keyed-min-heap-struct-index-map keyed-min-heap-in))
         (i (gethash key-in index-map)))
    (when i
      (let* ((ret-element (aref data-arr i))
             (last-i (1- (fill-pointer data-arr)))
             (last-val (aref data-arr last-i)))
        (decf (fill-pointer data-arr))
        (remhash key-in index-map)
        (unless (= i last-i)
          (setf (aref data-arr i) last-val)
          (setf (gethash (,extract-key-fn-name last-val) index-map)
                i)
          (,heapify-keyed-min-heap keyed-min-heap-in i))
        ret-element)))
)

;; inserts `element-in` into `keyed-min-heap-in`
;;   or if another element already is equivalent according to `key-hash-eql-fn`
;; returns `element-in`
(defun ,upsert-keyed-min-heap (keyed-min-heap-in element-in)
  (let* ((index-map (,keyed-min-heap-struct-index-map keyed-min-heap-in))
         (data-arr (,keyed-min-heap-struct-data keyed-min-heap-in))
         (key-in (,extract-key-fn-name element-in))
         (i (gethash key-in index-map)))
    (if i
      (progn
        (setf (aref data-arr i) element-in)
        (setf (gethash key-in index-map) i)
        (,heapify-keyed-min-heap keyed-min-heap-in i))
      (,--insert-keyed-min-heap keyed-min-heap-in element-in))
    element-in)
)

;; returns minimum element or `nil` if there are no elements
(defun ,peek-keyed-min-heap (keyed-min-heap-in)
  (unless (zerop (,size-keyed-min-heap keyed-min-heap-in))
    (aref (,keyed-min-heap-struct-data keyed-min-heap-in)
          0))
)

)
)
)
)
