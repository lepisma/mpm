;; Youtube playlist resolver

(import pafy)
(import [tqdm [tqdm]])
(require [mpm.macros [*]])

(defn create-url [dirty-yt-url]
  "Create a clean 11 digit id based url for keeping in db"
  (let [pafy-item (pafy.new :url dirty-yt-url :basic False)]
    (+ "yt:" pafy-item.videoid)))

(defn resolve-yt-playlist [source database]
  "Resolve youtube playlist"
  (raise (NotImplementedError)))
