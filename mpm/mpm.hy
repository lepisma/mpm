;; Main module for mpm

(import [mpm.resolvers.common [resolve]])
(import [mpm.resolvers.yt :as yt])
(import [mpm.db :as db])
(import [mpm.fs :as fs])
(import [sys [exit]])
(import [tqdm [tqdm]])
(require [mpm.macros [*]])

(defclass Mpm []
  (defn --init-- [self config]
    (setv self.config config)
    (setv self.database (db.get-dataset-conn (get self.config "database"))))

  (defn show-stats [self]
    "Return basic stats about the library"
    (print (+ "Total songs: " (str (db.count-rows self.database "songs")))))

  (defn show-song [self song-id]
    "Display information about song-id"
    (let [table (get self.database "songs")
          song (table.find-one :id song-id)]
      (for [k song]
        (color-print :info (.format "{0: <8}: " k)
                     :bold (str (get song k))))))

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

    (cond [url
           ;; This is a youtube import
           (let [url (yt.create-url url)
                 title (or title "NA")]
             (if (db.song-url-present? url self.database)
               (do
                (color-print :warn (+ url " already present."))
                (exit 1))
               (do
                (db.add-song self.database title url artist album)
                (color-print :info (+ url " added.")))))]
          [(and title (not url))
           ;; This is a player import
           (if (db.song-info-present? title artist self.database)
             (do
              (color-print :warn (+ title " - " artist " already present."))
              (exit 1))
             (do
              (db.add-song self.database title "NA" artist album)
              (color-print :info (+ title " - " artist " added."))))]
          [True
           ;; Fail
           (do
            (color-print :error "Invalid information for importing")
            (exit 1))]))

  (defn fix-urls [self]
    "Fix missing urls by filling in with youtube urls"
    (let [songs-to-fix (db.get-songs-without-url self.database)]
      (print (+ (str (len songs-to-fix)) " missing url(s)."))
      (for [song (tqdm songs-to-fix)]
        (let [yt-search-term (+ (get song "artist") " " (get song "title"))
              yt-url (yt.create-url (yt.search-yt yt-search-term))]
          (setv (get song "url") yt-url)
          (db.update-song self.database song ["id"])))))

  (defn fix-metadata [self]
    "Fix missing metadata. This is a mostly interactive step."
    (raise (NotImplementedError))))
