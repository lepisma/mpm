;; Indie script for correcting mtime in beets

(import dataset)
(import os)
(import [tqdm [tqdm]])

(def beet-db "/run/media/lepisma/Data/Music/beets.db")
(setv db (dataset.connect (+ "sqlite:///" beet-db)))
(setv table (get db "items"))

(defn get-mtime [fpath]
  (int (os.path.getmtime fpath)))

(for [item (tqdm (db.query "SELECT id, path FROM items"))]
  (setv mtime (get-mtime (get item "path")))
  (table.update (dict :id (get item "id")
                      :mtime mtime)
                ["id"]))
