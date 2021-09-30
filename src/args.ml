let convert = ref true
let sim = ref true
let no_sep = ref false
let no_print = ref false
let bench = ref false

let no_static = ref false

let speclist =
  [ "-bench", Arg.Set bench, "Run in benchmark mode. Outputs timing statistics for 10 runs."
  ; "-no_print", Arg.Set no_print, "Do not print the final quantum state. Useful for large states that would take too long to print."
  ; "-no_sim", Arg.Clear sim, "Do not run the quantum simulator to interpret the program. The interpreter will exit after static analyses."
  ; "-no_dynamic", Arg.Set no_sep, "Advanced: do not execute dynamic checks. The program will continue to execute in an unsafe manner."
  ; "-no_static", Arg.Set no_static, "Advanced: do not execute the static analysis. The program will execute in an unsafe manner."
  ; "-no_convert", Arg.Clear convert, "Advanced: do not attempt to automatically infer conversion operators. Programs that utilize this feature will be rejected."
  ]
;;
