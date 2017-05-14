(setv *doc* "Music package manager (mpm)

Usage:
  mpm source add <resolver> <name> <url> [--inc]
  mpm source (rm | remove) <name>
  mpm source (ls | list)
  mpm source (up | update) [<name>]
  mpm (ls | list) <query>
  mpm play <query>

  mpm -h | --help
  mpm -v | --version

Options:
  -h, --help     Show this screen.
  -v, --version  Show version.
  --inc          Incremental source. Handled as special case by resolver.")

(import [docopt [docopt]])
(import [mpm.mpm [Mpm]])
(require [mpm.macros [check-args]])

(defn cli []
  (let [args (docopt *doc* :version "mpm v0.1.0")
        m (Mpm)]
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
           (m.play (get args "<query>"))])))
