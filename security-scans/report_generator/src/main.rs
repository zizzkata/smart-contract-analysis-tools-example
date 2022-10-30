use std::process;
use slither_runner as slither;
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() <= 1 {
        println!("\nERROR: Please provide the name of the contract without '.sol'!\n");
        process::exit(1)
    }

    let contract_name = &args[1];

    let path = env::current_dir().expect("ERROR: Failed to get current path!");
    let path_string = path.to_str().expect("ERROR: can not convert path to string!");
    let result = slither::run_slither(path_string, contract_name);
    println!("Result: {}", result);
}
