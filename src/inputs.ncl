{
  parameters = {
    system       = 'string,
    unstable     = 'set,
    testpkgs     = 'set,
    pkgs         = 'set,
    root_inputs  = 'set,
    config       = 'set,
    filegen      = 'set,
    flakes       = 'set,
  },
  args = parameters
    |> std.record.map (fun name type => type |> match {
      'string => "${%{name}}",
      'set    => name,
    })
  ,
}
