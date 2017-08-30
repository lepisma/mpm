;; Main module for mpm

(import [mpm.resolvers.common [resolve]])
(import [mpm.db :as db])
(import [mpm.fs :as fs])
(require [mpm.macros [*]])

(defclass Mpm []
  "Class for working with source"

  (defn --init-- [self config]
    (setv self.config config)
    (setv self.database (db.get-dataset-conn (get self.config "database"))))

  (defn add-source [self resolver-name source-name url &optional [inc False]]
    "Add a source to database if resolver is present"
    (let [source (dict :resolver resolver-name
                       :name source-name
                       :url url
                       :inc inc)]
      (if (db.add-source self.database source)
        (color-print :info "Source added. Run `mpm source up` to update.")
        (color-print :warn "Source "
                     :bold name
                     :warn " already present in database. Skipping."))))

  (defn remove-source [self source-name]
    "Remove a source from database"
    (if (db.remove-source self.database source-name)
      (color-print :info "Source removed.")
      (color-print :warn "Some error.")))

  (defn list-sources [self]
    "Print all sources available"
    (for [source (db.list-sources self.database)]
      (color-print :bold (str (get source "id"))
                   :normal " ["
                   :info (+ (get source "resolver") (if (get source "inc") " (inc)" ""))
                   :normal "] "
                   :bold (get source "name")
                   :normal (+ " :: " (get source "url")))))

  (defn update-source [self &optional source-name]
    "Update information from sources. Optionally do this only for the
provided source."
    (if source-name
      (let [source (db.get-source self.database source-name)]
        (resolve source self.database))
      (for [source (source-list self.database)]
        (resolve source self.database))))

  (defn add-single [self &optional title url artist album]
    "Add a single song directly to database"
    (raise (NotImplementedError))))
