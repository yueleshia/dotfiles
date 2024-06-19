{
  parameters = {
    system       = 'string,
    unstable     = 'set,
    pkgs         = 'set,
    lib          = 'set,
    config       = 'set,
    username     = 'string,
    dotfiles_dir = 'string,
    filegen      = 'set,
  },
  args = parameters
    |> std.record.map (fun name type => type |> match {
      'string => "${%{name}}",
      'set    => name,
    })
  ,
}
