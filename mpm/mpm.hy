;; Main module for mpm

(import [mpm.resolvers.common [resolve]])
(import [mpm.db :as db])
(import [mpm.fs :as fs])
(import [sys [exit]])
(require [mpm.macros [*]])

(defclass Mpm []
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
      (do
       (color-print :error "Error in removing source.")
       (exit 1))))

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
      (for [source (db.list-sources self.database)]
        (resolve source self.database))))

  (defn add-song [self &optional title url artist album]
    "Add a single song directly to database"

    (cond [(and url (not title))
           ;; This is a youtube import
           (raise (NotImplementedError))]
          [(and title (not url))
           ;; This is a player import
           (raise (NotImplementedError))]
          [(and title url)
           ;; This is a complete import
           (raise (NotImplementedError))]
          [True
           ;; Fail
           (do
            (color-print :error "Invalid information for importing")
            (exit 1))])))
