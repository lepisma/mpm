(setv *doc* "Music package manager (mpm)

Usage:
  mpm add <resolver> <name> <url> [--inc] [--config=<CFG>]
  mpm (rm | remove) <name> [--config=<CFG>]
  mpm (ls | list) [--config=<CFG>]
  mpm (up | update) [<name>] [--config=<CFG>]

  mpm -h | --help
  mpm -v | --version

Options:
  -h, --help       Show this screen.
  -v, --version    Show version.
  --config=<CFG>   Path to config file [default: ~/.mpm.d/config]
  --inc            Incremental source. Handled as special case by resolver.")

(import [docopt [docopt]])
(import [mpm.mpm [Mpm]])
(import [mpm.fs [*]])
(import yaml)
(require [mpm.macros [check-args]])

(def *default-config* (dict :yt-cache (dict :limit 100
                                            :path "~/.mpm.d/yt-cache")
                            :database "~/.mpm.d/database"))

(defn get-config [config-file]
  "Return config after reading it from given file. Create a file if none exits."
  (with [cf (open (ensure-file config-file (yaml.dump *default-config*)))]
        (yaml.load cf)))

(defn cli []
  (setv args (docopt *doc* :version "mpm v0.1.0"))
  (setv m (Mpm (get-config (get args "--config"))))
  (cond [(check-args args (and "add"))
         (m.add-source (get args "<resolver>")
                       (get args "<name>")
                       (get args "<url>")
                       :inc (get args "--inc"))]
        [(check-args args (or "rm" "remove"))
         (m.remove-source (get args "<name>"))]
        [(check-args args (or "ls" "list"))
         (m.list-source)]
        [(check-args args (or "up" "update"))
         (m.update-source :source-name (get args "<name>"))]))
