(import [colorama [Fore Style]])
(import colorama)

(colorama.init :autoreset True)

(defmacro! this-or-that [o!x y]
  `(lif ~g!x ~g!x ~y))

(defmacro color-print [&rest args]
  (setv color-map {:warn (+ Fore.YELLOW Style.BRIGHT)
                   :info Fore.CYAN
                   :error (+ Fore.RED Style.BRIGHT)
                   :normal Fore.WHITE
                   :bold (+ Fore.WHITE Style.BRIGHT)}
        n (len args)
        i 0)
  (setv out-exp '())
  (while (< i n)
    (.append out-exp
             `(print (+ ~(get color-map (nth args i)) ~(nth args (+ i 1)))
                     :end ""))
    (setv i (+ i 2)))
  (.append out-exp '(print))
  `(do ~@out-exp))

(defmacro check-args [dict query]
  "Provide True/False check for docopt args."
  (setv acc '())
  (for [q query]
    (cond [(symbol? q) (.append acc q)]
          [(string? q) (.append acc `(get ~dict ~q))]
          [(coll? q) (.append acc `(check-args ~dict ~q))]))
  acc)

(defmacro query-list [return-cond from source-list where check-cond is item]
  "SQL-ish query on list"
  `(try
    (do
     (setv item-index (.index (list (map (fn [it] ~check-cond) ~source-list)) ~item))
     ((fn [it] ~return-cond) (nth ~source-list item-index)))
    (except [ValueError] False)))

(defmacro separate [predicate source-list]
  "Separate items depending on whether they satisfy the predicate.
First list is of True items, second is of False."
  `(do
    (setv true-items []
          false-items [])
    (list
     (map (fn [x] (if (~predicate x)
                    (.append true-items x)
                    (.append false-items x))) ~source-list))
    [true-items false-items]))
