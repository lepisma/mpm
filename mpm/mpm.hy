;; Main module for mpm

(import dataset)
(import [mpm.resolvers.common [resolve]])
(import [mpm.cache [YtCache]])
(import [mpm.fs [*]])
(require [mpm.macros [color-print]])


(defn source-add [source database]
  "Add source to the database"
  (setv table (get database "sources")
        name (get source "name"))
  (if (none? (table.find_one :name name))
    (do (table.insert source)
        (color-print :info "Source added. Run `mpm source up` to update."))
    (color-print :warn "Source "
                 :bold name
                 :warn " already present in database. Skipping.")))

(defn source-remove [source-name database]
  "Remove source identifier from the database"
  (setv table (get database "sources"))
  (table.delete :name source-name))

(defn source-list [database]
  "Return list of sources in the database"
  (setv table (get database "sources"))
  (table.all))

(defn get-dataset [database-path]
  "Return dataset connection"
  (dataset.connect (+ "sqlite:///" (get-full-path database-path))))

(defclass Mpm []
  "Class for working with source"

  (defn --init-- [self config]
    (setv self.config config)
    (setv self.database (get-dataset (get self.config "database")))
    (setv yt-cache-cfg (get self.config "yt_cache"))
    (setv self.yt-cache (YtCache (get yt-cache-cfg "path")
                                 (get yt-cache-cfg "limit"))))

  (defn add-source [self resolver-name source-name url &optional [inc False]]
    "Add a source to database if resolver is present"
    (source-add (dict :resolver resolver-name
                      :name source-name
                      :url url
                      :inc inc) self.database))

  (defn remove-source [self source-name]
    "Remove a source from database"
    (source-remove source-name self.database))

  (defn list-source [self]
    "Print all sources available"
    (for [source (source-list self.database)]
      (color-print :bold (str (get source "id"))
                   :normal " ["
                   :info (+ (get source "resolver") (if (get source "inc") " (inc)" ""))
                   :normal "] "
                   :bold (get source "name")
                   :normal (+ " :: " (get source "url")))))

  (defn update-source [self &optional [source-name None]]
    "Update information from sources. Optionally do this only for the
provided source."
    (for [source (source-list self.database)]
      (resolve source self.database))))
