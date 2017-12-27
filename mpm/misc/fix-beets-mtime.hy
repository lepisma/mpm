;; Script for correcting mtime in beets

(import dataset)
(import os)
(import sys)
(import [tqdm [tqdm]])

(setv beet-db (nth sys.argv 1))
(setv db (dataset.connect (+ "sqlite:///" beet-db)))
(setv table (get db "items"))

(defn get-mtime [fpath]
  (int (os.path.getmtime fpath)))

(for [item (tqdm (db.query "SELECT id, path, mtime FROM items"))]
  (unless (> (get item "mtime") 0)
    (do
      (setv mtime (get-mtime (get item "path")))
      (table.update (dict :id (get item "id")
                          :mtime mtime)
                    ["id"]))))
