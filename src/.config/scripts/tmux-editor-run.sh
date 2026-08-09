#!/bin/sh

#$1: filetype
#$2: path of file to parse

eval_escape() { <&0 sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"; }
die() { printf %s "${1}: " >&2; shift 1; printf %s\\n "$@" >&2; exit "${1}"; }

case "$#"
in 0|1)  die FATAL 1 "Missing arguments"
;; 2)    filetype="${1}"; path="${2}"
;; *)    die FATAL 1 "Too many arguments"
esac

[ -n "${TMUX}" ] || die FATAL 1 "Not running inside of tmux"

run_line="$( <"${path}" awk -v filetype="${filetype}" -v path="${path}" '
  BEGIN {
    r["awk_1"]        = "^ *#run:";                r["awk_2"]        = ""
    r["lua_1"]        = "^ *#run:";                r["lua_2"]        = ""
    r["perl_1"]       = "^ *#run:";                r["perl_2"]       = ""
    r["pl_1"]         = "^ *#run:";                r["pl_2"]         = ""
    r["ps1_1"]        = "^ *#run:";                r["ps1_2"]        = ""
    r["sh_1"]         = "^ *#run:";                r["sh_2"]         = ""

    r["py_1"]         = "^ *#run:";                r["py_2"]         = ""
    r["python_1"]     = "^ *#run:";                r["python_2"]     = ""
    r["go_1"]         = "^ *\\/\\/run:";           r["go_2"]         = ""
    r["rs_1"]         = "^ *\\/\\/run:";           r["rs_2"]         = ""
    r["rust_1"]       = "^ *\\/\\/run:";           r["rust_2"]       = ""
    r["java_1"]       = "^ *\\/\\/run:";           r["java_2"]       = ""
    r["js_1"]         = "^ *\\/\\/run:";           r["js_2"]         = ""
    r["roc_1"]        = "^ *#run:";                r["roc_2"]        = ""
    r["ts_1"]         = "^ *\\/\\/run:";           r["ts_2"]         = ""
    r["javascript_1"] = "^ *\\/\\/run:";           r["javascript_2"] = ""
    r["typescript_1"] = "^ *\\/\\/run:";           r["typescript_2"] = ""
    r["zig_1"]        = "^ *\\/\\/run:";           r["zig_2"]        = ""

    r["cue_1"]        = "^ *\\/\\/run:";           r["cue_2"]        = ""
    r["Dockerfile_1"] = "^ *#run:";                r["Dockerfile_2"] = ""
    r["ncl_1"]        = "^ *#run:";                r["ncl_2"]        = ""
    r["nix_1"]        = "^ *#run:";                r["nix_2"]        = ""
    r["tf_1"]         = "^ *#run:";                r["tf_2"]         = ""
    r["hcl_1"]        = "^ *#run:";                r["hcl_2"]        = ""

    r["html_1"]       = "^ *<!--run:";             r["html_2"]       = "-->.*$"
    r["sass_1"]       = "^ *\\/\\/run:";           r["sass_2"]       = ""
    r["scss_1"]       = "^ *\\/\\/run:";           r["scss_2"]       = ""
    r["rmd_1"]        = "^ *<!--run:";             r["rmd_2"]        = "-->.*$"
    r["md_1"]         = "^ *<!--run:|^ *`#run:";   r["md_2"]         = "-->.*$|`$"
    r["adoc_1"]       = "^ *\\/\\/run:|^ *`#run:"; r["adoc_2"]       = "`$|$"
    r["tmd_1"]        = "^`#run:";                 r["tmd_2"]        = "`$"
    r["tex_1"]        = "^ *%run:";                r["tex_2"]        = ""
    r["typ_1"]        = "^ *//run:";               r["typ_2"]        = ""

    if (r[filetype "_1"] == "" && r[filetype "_2"] == "") {
      exit_code = 1;
      exit;
    } else {
      exit_code = 2; # Use default if not found
    }
  }
  {
    lhs = r[filetype "_1"]
    rhs = r[filetype "_2"]

    if ($0 ~ lhs && $0 ~ rhs) {
      sub(lhs, "", $0);
      sub(rhs, "", $0);

      gsub(/@/, "@A", $0);
      gsub(/%%/, "@P", $0);
      gsub(/ %$/, " " path, $0);
      gsub(/ % /, " " path " ", $0);
      gsub(/^% /, " " path " ", $0);
      gsub(/@P/, "%", $0);
      gsub(/@A/, "@", $0);

      print $0;
      exit_code = 0; # Found run line
      exit 0;
    }
  }
  END {
    exit exit_code;
  }
' )"; code="$?"

case "${code}"
in 0) :
;; 1) notify.sh "Unsupported language: $0"; exit 1
;; 2) run_line="build.sh run --temp $( printf %s\\n "${path}" | eval_escape )"
esac

# Two spaces to not populate bash history
tmux-alt-pane.sh send-keys "  ${run_line}" Enter
