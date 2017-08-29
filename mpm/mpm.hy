;; Main module for mpm

(import os)
(import yaml)
(import dataset)
(import [mpm.resolvers.common [resolve]])
(import [mpm.cache [YtCache]])
(import [mpm.utils [*]])
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

(defclass Mpm []
  "Class for working with source"

  (defn --init-- [self config database-path]
    (setv self.config config)
    (setv self.database (dataset.connect (+ "sqlite:///" (ensure-file database-path))))
    (setv yt-cache (YtCache (ensure-dir (get self.config :youtube-cache))
                            (get self.config :cache-limit))))

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
      (resolve source self.database)))

  (defn search [self query]
    "List all songs matching the query"
    (setv table (get self.database "songs"))
    (for [song (table.all)]
      (print song)))

  (defn play [self query]
    "Play all songs matching the query"))
