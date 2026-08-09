#!/bin/sh
#ffprobe test.opus
#exiftool -artist=Ωmegata test.opus
#  https://exiftool.org/TagNames/Vorbis.html

# run: % ~/Music/test.opus
#run: % '/home/rai/Music/finished/ChiliChill; Miao Jiang - Rang Feng Gaosu Ni.opus'

main() {
  file="${1}"

  printf %s\\n "Reading: ${file}" >&2
  x="$( exiftool -G -json "${file}" )" || exit "$?"
  to_edit="$( printf %s\\n "${x}" | into_nickel )" || exit "$?"
  printf %s\\n "${to_edit}" | nickel eval >/dev/null || {
    printf %s\\n "Revise the script. Is invalid nickel file" >&2
    exit 1
  }
  #post_edit="${to_edit}"
  printf %s\\n "Editing..." >&2
  tempfile="$( mktemp )" || exit "$?"
  cleanup() {
    rm "${tempfile}"
  }
  trap 'cleanup' EXIT INT QUIT TERM

  printf %s\\n "Editing '${tempfile}'" >&2
  printf %s\\n "${to_edit}" >"${tempfile}"
  "${EDITOR}" "${tempfile}"
  post_edit="$( cat "${tempfile}" )" || exit "$?"

  printf %s\\n "" "=== Setting to ===" >&2
  printf %s\\n "${post_edit}" >&2
  nickel_checker="$(
    printf %s\\n "{"
    printf %s\\n "  inp,"
    printf %s\\n "  out | {"
    printf %s\\n "${field_list}" | jq --raw-input --slurp --raw-output 'split("\n") | map(select(. != "") |
                 "    \(.) | String | optional,"
    ) | join("\n")'
    printf %s\\n "  } = inp,"
    printf %s\\n "}"
  )"
  #printf %s\\n "${nickel_checker}"
  json_checked="$( printf %s\\n "${nickel_checker}" | nickel export --field out -- inp="${post_edit}" )" || exit "$?"

  printf %s\\n "" "=== Applying ===" >&2
  printf %s\\n "${json_checked}"
  fields="$( printf %s\\n "${json_checked}" | jq 'keys' )" || exit "$?"
  indices="$( printf %s\\n "${fields}" | jq 'range(length)' )" || exit "$?"

  for i in ${indices}; do
    field="$( printf %s\\n "${fields}" | jq --raw-output --argjson i "${i}" '.[$i]' )" || exit "$?"
    value="$( printf %s\\n "${json_checked}" | jq --raw-output --arg f "${field}" '.[$f]' )"
    opustags --in-place --set "${field}=${value}" "${file}"
  done
  #ffmpeg -i "${file}" -f opus -c:a copy "${args[@]}" "${tempfile}" || exit "$?"
  #cp "${tempfile}" "t.opus"


  printf %s\\n "" "=== Saved ===" >&2
  exiftool -G -json "${file}" | into_nickel >&2
}

field_list='
Actor
Album
Artist
Comment
Composer
Contact
Copyright
Date
Description
Director
Encoder
Genre
Isrc
License
Location
Organization
Performer
Producer
Title
TrackNumber
Vendor
Version

Language
Purl
'

into_nickel() (
  x="$( <&0 jq '.
    | .[0]
    | to_entries
    | map(select(.key | startswith("Vorbis:")))
    | map(.key |= sub("Vorbis:"; ""))
    | map(.value |= if type == "number" then tostring else . end)
    | from_entries
  ' )" || exit "$?"
  export x="${x}"

  <<EOF nickel export --format text --field out -- raw=@env:x
  {
    raw | String,
    json = raw |> std.deserialize 'Json,
    out = json
      |> std.record.to_array
      |> std.array.map (fun entry =>
        let field = if entry.field |> std.string.contains " " then std.serialize 'Json entry.field else entry.field in
        let indent = "  " in
        let format = fun x =>
          if std.typeof x == 'String
          then std.string.trim x
          else std.serialize 'Json x
        in

        entry.field |> match {
          "Description" => indent ++ m%"
            %{field} = %{"m%\""}
            %{
              (
                if entry.value == ""
                then ["", "Lyrics: ", "ED1", "", "=== Lyrics ==="]
                else entry.value |> std.string.split "\n"
              )
              |> std.array.map (fun x => if x == "" then "" else indent ++ indent ++ (format x))
              |> std.string.join "\n"
            }
            %{indent ++ "\"%"},
          "%,
          _ => indent ++ m%"%{field} = %{format entry.value |> std.serialize 'Json},"%,
        }
      )
      |> std.string.join "\n"
      |> (fun x => m%"
        # Put to empty string to delete entries
        {
        %{x}

        %{
          # Include these fields if not present
          [
            "Title",
            "Artist",
            "Album",
            "Composer",
            "Date",
            "Genre",
            "Performer",
            "Producer",
            "Director",
            "License",
            "TrackNumber",
            "Purl",
          ]
          |> std.array.filter (fun x => json |> std.record.has_field x |> (!))
          |> std.array.map (fun x => "  " ++ m%"%{x} = "","%)
          |> std.string.join "\n"
        }
        }

      "%)
    ,
  }
EOF
)

<&0 main "$@"
