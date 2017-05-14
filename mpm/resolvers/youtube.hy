(import pafy)
(import [tqdm [tqdm]])
(require [mpm.macros [color-print]])

(defn add-source-tag [item source-name table]
  "Add source name for the item in the table if not present."
  (let [old-sources (get item :sources)]
    (unless (in source-name old-sources)
      (do (setv (get item :sources) (+ old-sources "," source-name))
          (table.update item ["id"])))))

(defn add-pafy-item [item source-name table]
  "Insert pafy item in the table."
  (let [yid item.videoid
        title item.title
        item-in-table (table.find_one :pointer yid)]
    (if (none? item-in-table)
      (table.insert (dict :pointer yid
                          :title title
                          :sources source-name))
      ;; Append source name so that we can link to this song from this source
      (add-source-tag item-in-table source-name table))))

(defn processed? [item source-name table]
  "Return true if the item is already processed by `this` resolver."
  (let [item-in-table (table.find_one :yid item.videoid)]
    (if (none? item-in-table)
      False
      (in source-name (get item-in-table "sources")))))

(defn youtube [source database]
  "Resolve youtube links. Asks for a SOURCE and list of AVAILABLE items.
Return a list of items resolved"
  (let [source-name (get source "name")
        url (get source "url")
        inc (get source "inc")
        table (get database "songs")]
    (color-print :bold (+ "Resolving source " source-name))
    (if (in "watch" url)
      ;; This is a single video (ignoring playlist in the link)
      (try
       (add-pafy-item (pafy.new url :basic True) table)
       (except [Exception]))
      (let [plist (pafy.get_playlist2 url :basic True)
            pbar (tqdm (range (len plist)))]
        (for [pi (range (len plist))]
          (try
           (do (setv item (nth plist pi))
               (if (and inc (processed? item source-name table)
                        (do (color-print :warn "Reached end of incremental source")
                            (pbar.close)
                            (break))))
               (add-pafy-item item source-name table))
           (except [Exception])
           (finally (pbar.update 1))))))))
