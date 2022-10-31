use serde::{Deserialize, Serialize};
use serde_json::{Result, Value};
use std::any::type_name;
use std::fs;
use std::process;
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

// For Slither v0.9.0
// https://github.com/crytic/slither/tree/0.9.0
#[derive(Serialize, Deserialize)]
struct SlitherOutput {
    success: bool,
    error: Value,
    results: Value,
}

#[derive(Serialize, Deserialize)]
struct SlitherOutputHumanSummary {
    elements: Value,
    description: String,
    markdown: String,
    first_markdown_element: String,
    id: String,
    additional_fields: SlitherOutputHumanSummaryAdditionalFields,
    printer: String,
}

#[derive(Serialize, Deserialize)]
struct SlitherOutputHumanSummaryAdditionalFields {
    contracts: Value,
    number_lines: i32,
    number_lines_in_dependencies: i32,
    number_lines_assembly: i32,
    standard_libraries: Value,
    ercs: Vec<String>,
    number_findings: Value,
    detectors: Vec<SlitherOutputHumanSummaryAdditionalFieldsDetectors>,
    number_lines__dependencies: i32,
}

#[derive(Serialize, Deserialize)]
struct SlitherOutputHumanSummaryAdditionalFieldsDetectors {
    elements: Vec<Value>,
    description: String,
    markdown: String,
    first_markdown_element: String,
    id: String,
    check: String,
    impact: String,
    confidence: String,
}

#[derive(Serialize, Deserialize)]
struct SlitherOutputHumanSummaryAdditionalFieldsTypePragma {}

#[derive(Serialize, Deserialize)]
struct SlitherOutputHumanSummaryAdditionalFieldsTypeContract {}

#[derive(Serialize, Deserialize)]
struct SlitherOutputHumanSummaryAdditionalFieldsTypeFunction {}

#[derive(Serialize, Deserialize)]
struct SlitherOutputHumanSummaryAdditionalFieldsTypeNode {}

// Out of date: https://github.com/crytic/slither/wiki/JSON-output
pub fn format_output_to_markdown(prj_root_path: &str, contract_name: &str) -> Result<String> {
    let slither_json_path =
        format!("{prj_root_path}/security-scans/slither/results/{contract_name}/{contract_name}-output.json");

    let contents =
        fs::read_to_string(&slither_json_path).expect("Should have been able to read the file");

    let result: SlitherOutput = serde_json::from_str(&contents)?;

    if !result.success {
        println!("\nERROR: Slither had an error while running!\nSee {slither_json_path} for more info.\n");
        process::exit(1);
    }

    let mut slither_markdown = "".to_owned();

    let printers = &result.results["printers"];

    let printer_count = 1; // printers.len()
    for i in 0..printer_count {
        let current_printer = match printers[i]["printer"].as_str() {
            Some(s) => s,
            _ => "",
        };

        match current_printer {
            "human-summary" => {
                let tmpString = serde_json::to_string(&printers[i])?;

                let human_summary_result: SlitherOutputHumanSummary =
                    serde_json::from_str(&*tmpString)?;

                let human_summary_content =
                    format_printer_markdown_human_summary(human_summary_result);

                slither_markdown.push_str(&human_summary_content);
            }
            _ => println!("Printer ({}) not supported", current_printer),
        }
    }

    return Ok(slither_markdown);
}

fn format_printer_markdown_human_summary(json_data: SlitherOutputHumanSummary) -> String {
    let mut content = json_data.description;

    let other_content = "fdsafsdafsd";
    content.push_str(&format!("\n{}\n", other_content));

    return content;
}
