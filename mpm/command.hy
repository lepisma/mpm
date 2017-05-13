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
(import [mpm [mpm]])

(defn cli []
  (let [args (docopt *doc* :version "mpm v0.1.0")]
    (print (mpm.Mpm))))
