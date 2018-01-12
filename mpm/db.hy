;; Functions interacting with db

(import time)
(import dataset)
(require [high.macros [*]])

(defn get-dataset-conn [database-path]
  "Return dataset connection"
  (dataset.connect (+ "sqlite:///" #pdatabase-path)
                   :engine-kwargs {"connect_args" {"check_same_thread" False}}))

(defn source-present? [database source-name]
  "Check if source is present in the database"
  (let [table (get database "sources")]
       (not (none? (table.find-one :name source-name)))))

(defn add-source [database source]
  "Add source to the database"
  (setv table (get database "sources")
        source-name (get source "name"))
  (if (not (source-present? database source-name))
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
  (let [table (get database "sources")]
       (if (not (source-present? database source-name))
           (raise (Exception "Source not found"))
           (table.find-one :name source-name))))

(defn get-song [database song-id]
  "Return a song dict for given id"
  (let [table (get database "songs")]
       (table.find_one :id song-id)))

(defn get-songs-without-url [database]
  "Return songs without url"
  (let [table (get database "songs")]
       (list (table.find :url "NA"))))

(defn update-song [database song filter-keys]
  "Update song info"
  (let [table (get database "songs")]
       (table.update song filter-keys)))

(defn count-rows [database table-name]
  "Return row count for table-name"
  (len (get database table-name)))

(defn add-song [database title url artist album
                &optional [mtime (int (time.time))]]
  "Add a single song to database"
  (let [table (get database "songs")]
       (table.insert (dict :title title
                           :url url
                           :artist artist
                           :album album
                           :mtime mtime))))

(defn song-present? [database &kwargs kwargs]
  "Check if song identified by provided keywords is present in the db"
  (let [table (get database "songs")]
       (not (none? (apply table.find-one [] kwargs)))))
