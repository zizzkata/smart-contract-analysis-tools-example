use std::env;
use std::fs;
use std::process::Command;
use std::str;

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

// https://github.com/crytic/slither/wiki/JSON-output
//
/*
{
    "success": true,
    "error": null,
    "results": {
        "detectors": [
            {
                "check": "...",
                "impact": "...",
                "confidence": "...",
                "description": "...",
                "elements": [
                    {
                        "type": "...",
                        "name": "...",
                        "source_mapping": {
                            "start": 45
                            "length": 58,
                            "filename_relative": "contracts/tests/constant.sol",
                            "filename_absolute": "/tmp/contracts/tests/constant.sol",
                            "filename_short": "tests/constant.sol",
                            "filename_used": "contracts/tests/constant.sol",
                            "lines": [
                                5,
                                6,
                                7
                            ],
                            "starting_column": 1,
                            "ending_column": 24,
                        },
                        "type_specific_fields": {},
                        "additional_fields": {
                            https://github.com/crytic/slither/wiki/JSON-output#detector-specific-additional-fields
                        }
                    }
                ]
            }
        ],
        "upgradeability-check": {}
    }
}
 */
pub fn format_output_to_markdown(prj_root_path: &str, contract_name: &str) {
    let slither_json_path =
        format!("{prj_root_path}/security-scans/slither/results/{contract_name}/{contract_name}-output.json");

    println!("In file {}", slither_json_path);

    let contents =
        fs::read_to_string(slither_json_path).expect("Should have been able to read the file");

    println!("With text:\n{contents}");
}
