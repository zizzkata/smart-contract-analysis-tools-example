use serde_json::{Result, Value};
use std::any::type_name;
use std::env;
use std::fs;
use std::process::Command;
use std::str;

fn type_of<T>(_: T) -> &'static str {
    type_name::<T>()
}

pub fn run_slither(prj_root_path: &str, contract_name: &str) -> String {
    // TODO: see if sudo can be removed
    let command = format!(
        "sudo ./security-scans/slither/run-slither.sh {} {}",
        prj_root_path, contract_name
    );

    let result = Command::new("sh")
        .arg("-c")
        .arg(command)
        .output()
        .expect("failed to execute process");

    let output = match str::from_utf8(&result.stdout) {
        Ok(v) => v,
        Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
    };

    return output.to_string();
}

// Check if strongly typed output if possible with optional fields
// Out of date: https://github.com/crytic/slither/wiki/JSON-output
pub fn format_output_to_markdown(prj_root_path: &str, contract_name: &str) -> Result<()> {
    let slither_json_path =
        format!("{prj_root_path}/security-scans/slither/results/{contract_name}/{contract_name}-output.json");

    let contents =
        fs::read_to_string(slither_json_path).expect("Should have been able to read the file");

    println!("{contents}");

    let result: Value = serde_json::from_str(&contents)?;

    println!("{}", result["success"]);

    let printers = &result["results"]["printers"];

    println!("{}", type_of(printers));

    let printer_count = 1; // printers.len()
    for i in 0..printer_count {
        let current_printer = match printers[i]["printer"].as_str() {
            Some(s) => s,
            _ => "",
        };

        let printer_data = &printers[i];

        match current_printer {
            "human-summary" => format_printer_markdown_human_summary(printer_data),
            _ => println!("Printer ({}) not supported", current_printer),
        }
    }

    Ok(())
}

fn format_printer_markdown_human_summary(json_data: &Value) {}
