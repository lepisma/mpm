(setv *doc* "Music package manager (mpm)

Usage:
  mpm source add <resolver> <name> <url> [--inc] [--config=<CFG>]
  mpm source (rm | remove) <name> [--config=<CFG>]
  mpm source (ls | list) [--config=<CFG>]
  mpm source (up | update) [<name>] [--config=<CFG>]
  mpm (ls | list) <query> [--config=<CFG>]

  mpm -h | --help
  mpm -v | --version

Options:
  -h, --help       Show this screen.
  -v, --version    Show version.
  --config=<CFG>   Path to config file [default: ~/.mpm.d/config]
  --inc            Incremental source. Handled as special case by resolver.")

(import [docopt [docopt]])
(import [mpm.mpm [Mpm]])
(import sys)
(require [mpm.macros [check-args]])

(def *default-yt-cache* "~/.mpm.d/yt-cache"
  *default-database* "~/.mpm.d/database")

(defn get-config [config-file]
  "Return config after reading it from given file. Create a file if none exits."
  (with [cf (open (ensure-file config-file
                               (yaml.dump (dict :youtube-cache *default-yt-cache*
                                                :database *default-database*))))]
        (yaml.load cf)))

(defn cli []
  (setv args (docopt *doc* :version "mpm v0.1.0"))

  (setv m (Mpm ))
        ;;m (Mpm)
  (cond [(check-args args (and "source" "add"))
         (m.add-source (get args "<resolver>")
                       (get args "<name>")
                       (get args "<url>")
                       :inc (get args "--inc"))]
        [(check-args args (and "source" (or "rm" "remove")))
         (m.remove-source (get args "<name>"))]
        [(check-args args (and "source" (or "ls" "list")))
         (m.list-source)]
        [(check-args args (and "source" (or "up" "update")))
         (m.update-source :source-name (get args "<name>"))]
        [(check-args args (or "ls" "list"))
         (m.search (get args "<query>"))]
        [(check-args args ("play")) True
         (m.play (get args "<query>"))]))
