(import [colorama [Fore]])
(import colorama)

(colorama.init :autoreset True)

(defmacro! this-or-that [o!x y]
  `(lif ~g!x ~g!x ~y))

(defmacro color-print [&rest args]
  (let [color-map {:warn Fore.YELLOW
                   :info Fore.BLUE
                   :error Fore.RED
                   :normal Fore.WHITE}
        n (len args)
        i 0]
    (setv out-exp '())
    (while (< i n)
      (.append out-exp
               `(print (+ ~(get color-map (nth args i)) ~(nth args (+ i 1)))
                       :end ""))
      (setv i (+ i 2)))
    (.append out-exp '(print))
    `(do ~@out-exp)))

(defmacro check-args [dict query]
  "Provide True/False check for docopt args."
  (let [acc '()]
    (for [q query]
      (cond [(symbol? q) (.append acc q)]
            [(string? q) (.append acc `(get ~dict ~q))]
            [(coll? q) (.append acc `(check-args ~dict ~q))]))
    acc))
