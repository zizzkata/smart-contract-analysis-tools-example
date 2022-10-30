use std::env;
use std::process;

// Import the different tools
use slither_runner as slither;
use smtchecker_runner as smtchecker;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() <= 1 {
        println!("\nERROR: Please provide the name of the contract without '.sol'!\n");
        process::exit(1)
    }

    let contract_name = &args[1];

    let path = env::current_dir().expect("ERROR: Failed to get current path!");
    let path_string = path
        .to_str()
        .expect("ERROR: can not convert path to string!");

    println!("Running Slither");

    let result = slither::run_slither(path_string, contract_name);
    println!("{}", result);

    println!("Running SMTChecker");

    let result = smtchecker::run_smtchecker(path_string, contract_name);
    println!("{}", result);
}
