(import pafy)
(import [tqdm [tqdm]])
(require [mpm.macros [color-print query-list separate]])

(defn add-source-tag [item source-name table]
  "Add source name for the item in the table."
  (setv (get item "sources") (+ (get item "sources") "," source-name))
  (table.update item ["id"]))

(defn add-tags-to-table [entries source-name table table-rows]
  "Add self source tag for entries in the table. Assume entries are present."
  (map (fn [x]
         (add-source-tag
          (query-list it from table-rows where (get it "pointer") is x.videoid)
          source-name table)) entries))

(defn add-entries-to-table [entries source-name table]
  "Add entries to table in batch"
  (table.insert_many (map (fn [x] (dict :pointer x.videoid
                                        :title x.title
                                        :sources source-name)) entries)))

(defn present? [item table-rows]
  "Check if the item it present in rows"
  (in item.videoid (map (fn [x] (get x "pointer")) table-rows)))

(defn processed? [item source-name table-rows]
  "Return true if the item is already processed by `this` resolver."
  (query-list (in source-name (get it "sources")) from table-rows
               where (get it "pointer") is item.videoid))

(defn youtube [source database]
  "Resolve youtube links. Asks for a SOURCE and list of AVAILABLE items.
Return a list of items resolved"
  (let [source-name (get source "name")
        url (get source "url")
        inc (get source "inc")
        table (get database "songs")
        all-songs (list (map identity (table.all)))]
    (color-print :bold (+ "Resolving source " source-name))
    (if (in "watch" url)
      ;; This is a single video (ignoring playlist in the link)
      ;; Should remove this, a better solution is a file list based resolver
      (raise (NotImplementedError))
      ;; This is a playlist
      (let [plist (pafy.get_playlist2 url :basic True)
            piter (iter plist)
            entries []]
        (for [_ (tqdm (range (len plist)))]
          (try
           (do (setv pitem (next piter))
               (if (and inc (processed? pitem source-name all-songs)
                        (do (color-print :warn "Reached end of incremental source")
                            (break))))
               (.append entries pitem))
           (except [Exception] (print "sdsd"))))
        (let [[to-tag to-add] (separate (fn [x] (present? x all-songs)) entries)]
          (add-tags-to-table to-tag source-name table all-songs)
          (add-entries-to-table to-add source-name table))))))
