use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::process;

// Import the different tools
use slither_runner as slither;
use smtchecker_runner as smtchecker;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() <= 1 {
        println!("\nERROR: Please provide the name of the contract without '.sol'!\n");
        process::exit(1);
    }

    let contract_name = &args[1];

    let path = env::current_dir().expect("ERROR: Failed to get current path!");
    let path_string = path
        .to_str()
        .expect("ERROR: can not convert path to string!");

    let filePath = format!("{path_string}/security-scans/report-{contract_name}.md");
    let mut file = match create_file(&filePath) {
        Ok(f) => f,
        _ => {
            println!("\nERROR: Failed to create file: {}\n", filePath);
            process::exit(1);
        }
    };

    let main_header = "# Code report\n\n";
    write_to_report(&mut file, &main_header);

    //---------------
    // Slither
    //---------------

    let slither_header = "## Slither\n\n";
    write_to_report(&mut file, &slither_header);

    let result = slither::run_slither(path_string, contract_name);

    let slither_markdown_content =
        match slither::format_output_to_markdown(path_string, contract_name) {
            Ok(s) => s,
            _ => "".to_string(),
        };

    write_to_report(&mut file, &slither_markdown_content);

    //---------------
    // SMTChecker
    //---------------

    // let result = smtchecker::run_smtchecker(path_string, contract_name);
    // println!("{}", result);
}

fn create_file(file_name: &str) -> std::io::Result<File> {
    let file = File::create(file_name)?;
    return Ok(file);
}

fn write_to_report(file: &mut File, content: &str) -> std::io::Result<()> {
    file.write_all(content.as_bytes())?;
    Ok(())
}
