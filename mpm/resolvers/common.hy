(import [mpm.resolvers.yt [resolve-yt-playlist]])
(import [mpm.resolvers.beets [resolve-beets]])
(require [mpm.macros [*]])

(defn resolve [source database]
  "Main link resolving function"
  ((this-or-that (.get (globals) (+ "resolve_" (get source "resolver")))
                 (raise NotImplementedError))
   source database))
