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

(defn add-song [database title url artist album
                &optional [mtime (int (time.time))]]
  "Add a single song to database"
  (raise (NotImplementedError)))
