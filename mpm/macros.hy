(defmacro! this-or-that [o!x y]
  `(if (is ~g!x None) ~y ~g!x))
