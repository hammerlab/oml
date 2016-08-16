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
            Pathname.define_context "src/lib/unc"   ["src/lib/util"; "src/lib/unc"];
            Pathname.define_context "src/lib/stats" ["src/lib/util"; "src/lib/unc"; "src/lib/stats"];
            Pathname.define_context "src/lib/cls"   ["src/lib/util"; "src/lib/unc"; "src/lib/stats"; "src/lib/cls"];
            Pathname.define_context "src/lib/rgr"   ["src/lib/util"; "src/lib/unc"; "src/lib/stats"; "src/lib/rgr"];
            Pathname.define_context "src/lib/uns"   ["src/lib/util"; "src/lib/unc"; "src/lib/uns"];

            if target_with_extension "test" then begin
              rule "concat ml and mlt files"
                (*~insert:(`before "ocaml dependencies ml") *)
                ~insert:`top
                ~prod:"%.mlj"
                ~deps:["%.mlt"; "%.ml"]
                begin fun env _build ->
                  let () = Printf.printf "oh boy!\n" in
                  let ml  = env "%.ml" in
                  let mlt = env "%.mlt" in
                  let mlj = env "%.mlj" in
                  Cmd ( S [ A "cat" ; P ml ; P mlt ; Sh ">" ; P mlj ])
                end;

              rule "ocaml dependencies mlj"
                ~insert:(`before "ocaml dependencies ml")
                ~prod:"%.ml.depends"
                ~dep:"%.mlj"
                ~doc:"foo"
                (*Ocaml_tools.ocamldep_command "%.mlj" "%.ml.depends"); *)
                begin fun env _build ->
                  let ml  = env "%.ml" in
                  let mlj = env "%.mlj" in
                  let mld = env "%.ml.depends" in
                  let tags = tags_of_pathname ml ++ "ocaml" ++ "ocamldep" in
                  Cmd(S[A "ocamlfind"; A "ocamldep"; T tags; A "-ml-synonym"; Sh "'.mlj'"; A "-modules"; P mlj; Sh ">"; Px mld])
                end;

              (*rule "ocaml: mlj & cmi -> cmo"
                ~insert:(`before "ocaml: ml & cmi -> cmo")
                ~deps:[ "%.mli"; "%.mlj"; "%.ml.depends"; "%.cmi" ]
                ~prods:[ "%.cmo" ]
                (Ocaml_compiler.byte_compile_ocaml_implem "%.mlj" "%.cmo"); *)

              rule "ocaml: mlj & cmi -> cmx & o"
                ~insert:(`before "ocaml: ml & cmi -> cmx & o")
                ~prods:["%.cmx"; "%" -.- !Options.ext_obj ]
                ~deps:["%.mlj"; "%.ml.depends"; "%.cmi"]
                begin fun env _build ->
                  let ml  = env "%.ml" in
                  let mlj = env "%.mlj" in
                  let cmx = env "%.cmx" in
                  let tags = tags_of_pathname ml ++ "ocaml" ++ "implem" in
                  Cmd(S[A "ocamlfind"; A "ocamlopt"; T tags; A "-I"; A "src/lib"; A "-o"; P cmx; A "-impl"; P mlj])
                end;
                (*Ocaml_compiler.native_compile_ocaml_implem "%.mlj"*)
            end;

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
            (* To build without interfaces
            rule "ocaml-override: ml -> cmo & cmi"
              ~insert:`top
              ~prods:["%.cmo"; "%.cmi"]
              ~deps:["%.ml"; "%.ml.depends"]
              ~doc:"This rule disables mli files."
              (Ocaml_compiler.byte_compile_ocaml_implem "%.ml" "%.cmo") ;
            *)
            (* For documentation. *)
            if target_with_extension "html" then begin
              (* Insert Oml_array.mli into the
                'include (module type of Oml_array)'
                so taht we can have the signature for documentation. *)
              let from_file = "src/lib/util/util.mli" in
              let to_file   = "_build/src/lib/util/util.mli" in
              let perl_mat  = "include \\(module type of Oml_array\\)" in
              let command   =
                Printf.sprintf
                  "perl -pe 's/%s/`cat src\\/lib\\/util\\/oml_array.mli`/ge' %s > %s"
                    perl_mat from_file to_file
              in
              ignore (Sys.command "mkdir -p _build/src/lib/util");
              Printf.printf "%s\n" command;
              ignore (Sys.command command);
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
                    let fname = dir / String.lowercase_ascii (mdl ^ ".mli") in
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
