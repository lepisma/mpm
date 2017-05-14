(import [mpm.resolvers.youtube [youtube]])
(require [mpm.macros [this-or-that]])

(defn resolve [source database]
  "Main link resolving function"
  ((this-or-that (.get (globals) (get source "resolver"))
                 (raise NotImplementedError))
   source database))
