;; Source to url resolvers

(require [mpm.macros [this-or-that]])

(defn youtube [source available]
  "Resolve youtube links. Asks for a SOURCE and list of AVAILABLE items.
Return a list of items resolved"

  (if (in (get source "url") available)
    []
    ([(get source "url")])))

(defn get-resolver [identifier]
  "Return handler by string"
  (this-or-that (.get (globals) identifier) (raise NotImplementedError)))
