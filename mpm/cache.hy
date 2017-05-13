;; Youtube cache module

(import [threading [Lock Thread]])
(import [glob [glob]])
(import [os [path unlink]])
(import pafy)

(defn item-pair [file-path]
  "Return a list of items [name modified-time] for FILE-PATH"
  [(path.basename file-path) (path.getmtime file-path)])

(defclass YtCache []
  "Cache for youtube with a kick limit"

  (defn --init-- [self cache-path limit]
    (setv self.cache-path (path.expanduser cache-path))
    (setv self.limit limit)
    (let [files (glob (path.join self.cache-path "*"))]
      (setv self.cached (list (map item-pair files))))
    (setv self.list-lock (Lock)))

  (defn -update-list [self file-path]
    "Add given file to the list"
    (if (> (len self.cached) self.limit)
      (let [oldest (min self.cached :key (fn [x] (last x)))]
        (unlink (path.join self.cache-path (first oldest)))
        (self.cached.remove oldest)))
    (self.cached.append (item-pair file-path)))

  (defn -download [self pafy-stream file-path]
    "Download from the stream"
    ((. pafy-stream download) file-path :quiet True)
    (with [self.list-lock]
          (self.-update-list file-path)))

  (defn get [self yt-id &optional [stream True]]
    "Get item for given YT-ID. Optionally provide a streaming url."
    (let [file-path (path.join self.cache-path yt-id)]

      (if (in yt-id (map (fn [f] (first f)) self.cached))
        file-path
        (let [audio-stream (.getbestaudio (pafy.new yt-id))]
          (if stream
            (do
             (.start (Thread :target self.-download :args [audio-stream file-path]))
             audio-stream.url_https)
            (do
             (self.-download audio-stream file-path)
             file-path)))))))
