(import [mpm.resolvers.yt [resolve-yt-playlist]])
(import [mpm.resolvers.beets [resolve-beets]])

(defn resolve [source database]
  "Main link resolving function"
  ((or (.get (globals) (+ "resolve_" (get source "resolver")))
       (raise NotImplementedError))
    source database))
