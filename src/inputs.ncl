{
  parameters = {
    unstable     = 'set,
    testpkgs     = 'set,
    pkgs         = 'set,
    config       = 'set,
  },
  args = parameters
    |> std.record.map (fun name type => type |> match {
      'string => "${%{name}}",
      'set    => name,
    })
  ,
}
