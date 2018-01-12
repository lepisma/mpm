;; Beets resolver

(import [mpm.db :as db])
(import [tqdm [tqdm]])
(require [high.macros [*]])

(defn resolve-beets [source database]
  "Resolve from beets database. Asks for a SOURCE and handle to DATABASE."

  (let [beets-db (db.get-dataset-conn (get source "url"))
        beets-table (get beets-db "items")]
       (for [item (tqdm (beets-db.query "SELECT title, artist, album, id, mtime FROM items"))]
         (let [song-url (+ "beets:" (str (get item "id")))]
              (unless (db.song-present? database :url song-url)
                (db.add-song database
                             (get item "title")
                             song-url
                             (get item "artist")
                             (get item "album")
                             :mtime (get item "mtime")))))))
