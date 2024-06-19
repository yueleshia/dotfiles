#run: nickel export % --field text --format raw

let dirs = (import "../../profiles.ncl").current_profile.named_directories in

{ executable = false, text = m%"
; npm ini config file, see `npm help config`
;;;;
; cache=%{dirs.h}/.npm
; cache-lock-stale=60000
; cache-lock-retries=10
; cache-lock-wait=10000
; cache-max=null
; cache-min=10
; globalconfig=/usr/etc/npmrc
; init-module=%{dirs.h}/.npm-init.js
; init-author-name=
; init-author-email=
; init-author-url=
; init-version=1.0.0
; init-license=ISC
; prefix=/usr
; user-agent=npm/{npm-version} node/{node-version} {platform} {arch}
; registry=https://registry.npmjs.org/
; script-shell=null
; shell=/bin/bash
; tmp=/tmp
; userconfig=%{dirs.h}/.npmrc
; globalignorefile=/usr/etc/npmignore

"% }
