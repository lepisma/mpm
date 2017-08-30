(setv *doc* "Music package manager (mpm)

Usage:
  mpm source add <resolver> <name> <url> [--inc] [--config=<CFG>]
  mpm source (rm | remove) <name> [--config=<CFG>]
  mpm source (ls | list) [--config=<CFG>]
  mpm source (up | update) [<name>] [--config=<CFG>]
  mpm add [--title=<TITLE>] [--url=<URL>] [--artist=<ARTIST>] [--album=<ALBUM>]

  mpm -h | --help
  mpm -v | --version

Options:
  -h, --help       Show this screen.
  -v, --version    Show version.
  --config=<CFG>   Path to config file [default: ~/.mpm.d/config]
  --inc            Incremental source. Handled as special case by resolver.")

(import [docopt [docopt]])
(import [mpm.mpm [Mpm]])
(import [mpm.fs :as fs])
(import yaml)
(require [mpm.macros [*]])

(def *default-config* (dict :database "~/.mpm.d/database"))

(defn get-config [config-file]
  "Return config after reading it from given file. Create a file if none exits."
  (with [cf (open (fs.ensure-file config-file (yaml.dump *default-config*)))]
        (yaml.load cf)))

(defn cli []
  (setv args (docopt *doc* :version "mpm v0.1.0"))
  (setv m (Mpm (get-config (get args "--config"))))
  (cond [(check-args args (and "source" "add"))
         (m.add-source (get args "<resolver>")
                       (get args "<name>")
                       (get args "<url>")
                       :inc (get args "--inc"))]
        [(check-args args (and "source" (or "rm" "remove")))
         (m.remove-source (get args "<name>"))]
        [(check-args args (and "source" (or "ls" "list")))
         (m.list-sources)]
        [(check-args args (and "source" (or "up" "update")))
         (m.update-source :source-name (get args "<name>"))]
        [(check-args args (and "add"))
         (m.add-song :title (get args "--title")
                     :url (get args "--url")
                     :artist (get args "--artist")
                     :album (get args "--album"))]))
