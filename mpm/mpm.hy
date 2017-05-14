;; Main module for mpm

(import os)
(import yaml)
(import dataset)
(import [mpm.resolvers [get-resolver]])
(import [mpm.utils [*]])
(require [mpm.macros [color-print]])

(setv *config-env-var* "MPM_CONFIG_FILE")
(setv *default-config-file* "~/.mpm.yaml")
(setv *default-yt-cache* "~/.yt-cache")
(setv *default-database* "~/.mpm.db")


(defn get-config [config-file]
  "Return config after reading it from given file. Create a file if none exits."

  (with [cf (open (g-file config-file
                          (yaml.dump {:youtube-cache *default-yt-cache*
                                      :database *default-database*})))]
        (yaml.load cf)))

(defn source-add [source database]
  "Add source to the database"
  (let [table (get database "sources")
        name (get source "name")]
    (if (none? (table.find_one :name name))
      (table.insert source)
      (color-print :warn "Source "
                   :normal name
                   :warn " already present in database. Skipping."))))

(defn source-remove [source-name database]
  "Remove source identifier from the database"
  (let [table (get database "sources")]
    (table.delete :name source-name)))

(defn source-list [database]
  "Return list of sources in the database"
  (let [table (get database "sources")]
    (table.all)))

(defclass Mpm []
  "Class for working with source"

  (defn --init-- [self]
    (let [config-file (if (in *config-env-var* os.environ)
                        (get os.environ *config-env-var*)
                        *default-config-file*)]
      (setv self.config (get-config config-file)))

    (let [database-file (g-file (get self.config :database))]
      (setv self.database (dataset.connect (+ "sqlite:///" database-file)))))

  (defn add-source [self resolver-name source-name url &optional [inc False]]
    "Add a source to database if resolver is present"
    (source-add {"resolver"
                 resolver-name
                 "name"
                 source-name
                 "url"
                 url
                 "inc"
                 inc} self.database))

  (defn remove-source [self source-name]
    "Remove a source from database"
    (source-remove source-name self.database))

  (defn list-source [self]
    "Print all sources available"
    (for [item (source-list self.database)]
      (color-print :bold (str (get item "id"))
                   :normal " ["
                   :info (+ (get item "resolver") (if (get item "inc") " (inc)" ""))
                   :normal "] "
                   :bold (get item "name")
                   :normal (+ " :: " (get item "url")))))

  (defn update-source [self &optional [source-name None]]
    "Update information from sources. Optionally do this only for the
provided source.")

  (defn search [self query]
    "List all songs matching the query")

  (defn play [self query]
    "Play all songs matching the query"))
