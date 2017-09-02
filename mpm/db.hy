;; Functions interacting with db

(import time)
(import dataset)
(import [mpm.fs :as fs])
(require [mpm.macros [*]])

(defn get-dataset-conn [database-path]
  "Return dataset connection"
  (dataset.connect (+ "sqlite:///" (fs.get-full-path database-path))))

(defn add-source [database source]
  "Add source to the database"
  (setv table (get database "sources")
        name (get source "name"))
  (if (none? (table.find_one :name name))
    (do (table.insert source) True)
    False))

(defn remove-source [database source-name]
  "Remove given source from the database"
  (let [table (get database "sources")]
    (table.delete :name source-name)))

(defn list-sources [database]
  "Return a list of all sources in database"
  (let [table (get database "sources")]
    (table.all)))

(defn get-source [database source-name]
  "Return a source dict for given name"
  (raise (NotImplementedError)))

(defn get-song [database song-id]
  "Return a song dict for given id"
  (let [table (get database "songs")]
    (table.find_one :id song-id)))

(defn add-song [database title url artist album
                &optional [mtime (int (time.time))]]
  "Add a single song to database"
  (let [table (get database "songs")]
    (table.insert (dict :title title
                        :url url
                        :artist artist
                        :album album
                        :mtime mtime))))

(defn song-info-present? [title artist database]
  "Check if song identified by title and artist is present"
  (.find_one (get database "songs") :title title :artist artist))

(defn song-url-present? [song-url database]
  "Check if song url is present in database"
  (.find_one (get database "songs") :url song-url))
