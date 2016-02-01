open Ocamlbuild_plugin
open Ocamlbuild_pack

let target_with_extension ext =
  List.exists (fun s -> Pathname.get_extension s = ext) !Options.targets

let () =
  let additional_rules =
    function
      | Before_hygiene  -> ()
      | After_hygiene   -> ()
      | Before_options  -> ()
      | After_options   -> ()
      | Before_rules    -> ()
      | After_rules     ->
          begin
            (* TODO: Can we automatically generate these path dependencies? *)
            Pathname.define_context "src/lib/unc"   ["src/lib/util"; "src/lib/unc"];
            Pathname.define_context "src/lib/stats" ["src/lib/util"; "src/lib/unc"; "src/lib/stats"];
            Pathname.define_context "src/lib/cls"   ["src/lib/util"; "src/lib/unc"; "src/lib/stats"; "src/lib/cls"];
            Pathname.define_context "src/lib/rgr"   ["src/lib/util"; "src/lib/unc"; "src/lib/stats"; "src/lib/rgr"];
            Pathname.define_context "src/lib/uns"   ["src/lib/util"; "src/lib/unc"; "src/lib/uns"];

            rule "Create a test target."
              ~prod:"%.test"
              ~dep:"%.native"
              begin fun env _build ->
                let test = env "%.test" and native = env "%.native" in
                Seq [ mv native test
                    ; Cmd (S [ A "ln"
                             ; A "-sf"
                             ; P (!Options.build_dir/test)
                             ; A Pathname.parent_dir_name])
                ]
              end;
            (* For documentation. *)
            if target_with_extension "html" then begin
              rule "Create mli from mlpack."
                ~prod:"%.mli"
                ~deps:["%.mlpack"; "%.mlipack"]
                begin fun env _build ->
                  let pck = env "%.mlpack" in
                  let pcki = env "%.mlipack" in
                  let dir = Pathname.pwd / Pathname.dirname pck in
                  let mli = !Options.build_dir / env "%.mli" in
                  string_list_of_file pck
                  |> List.map (fun mdl ->
                    let fname = dir / String.lowercase (mdl ^ ".mli") in
                    let mdlfl = env fname in
                    if Pathname.exists mdlfl then begin
                      [ Sh (Printf.sprintf "echo module %s : sig >>" mdl)
                      ; P mli
                      ; Sh ";"
                      ; Sh (Printf.sprintf "cat %s >>" mdlfl)
                      ; P mli
                      ; Sh ";"
                      ; Sh "echo end >>"
                      ; P mli
                      ; Sh ";"
                      ]
                    end else
                      [])
                  |> List.concat
                  |> fun lst ->
                      let nlst = Sh (Printf.sprintf "cat %s >>" pcki)
                                 :: P mli
                                 :: Sh ";"
                                 :: lst
                      in
                      Cmd (S nlst)
                end
            end
          end
  in
  dispatch additional_rules
