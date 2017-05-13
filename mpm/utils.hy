(import [os [path]])
(import os)

(defn g-file [file-path &optional [default-data ""]]
  "Create file if not exists with default-data and return path."
  (let [full-path (path.expanduser file-path)]
    (if (not (path.exists full-path))
      (with [f (open full-path "w")]
            (f.write default-data)))
    full-path))

(defn g-dir [dir-path]
  "Create directory if not exists and return path."
  (let [full-path (path.expanduser dir-path)]
    (if (not (path.exists full-path))
      (os.makedirs full-path))
    full-path))
