;; Youtube playlist resolver

(import pafy)
(import [tqdm [tqdm]])
(import requests)
(import [eep [Searcher]])
(require [mpm.macros [*]])

(defn create-url [dirty-yt-url]
  "Create a clean 11 digit id based url for keeping in db"
  (let [pafy-item (pafy.new :url dirty-yt-url :basic False)]
    (+ "yt:" pafy-item.videoid)))

(defn search-yt [search-term]
  "Search for term in youtube and return first youtube url"
  (let [params (dict :search_query search-term)
        res (requests.get "https://youtube.com/results" :params params)
        es (Searcher res.text)]
    (es.search-forward "watch?v=")
    (+ "https://youtube.com/" (es.get-sub :end (+ 11 es.point)))))

(defn resolve-yt-playlist [source database]
  "Resolve youtube playlist"
  (raise (NotImplementedError)))
