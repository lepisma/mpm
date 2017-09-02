(import [os [path]])
(import os)
(require [mpm.macros [*]])

(defn ensure-file [file-path &optional [default-data ""]]
  "Create file if not exists with default-data and return path."
  (setv full-path #pfile-path)
  (ensure-dir (path.dirname full-path))

  (if (not (path.exists full-path))
    (with [f (open full-path "w")]
          (f.write default-data)))
  full-path)

(defn ensure-dir [dir-path]
  "Create directory if not exists and return path."
  (setv full-path #pdir-path)
  (if (not (path.exists full-path))
    (os.makedirs full-path))
  full-path)
