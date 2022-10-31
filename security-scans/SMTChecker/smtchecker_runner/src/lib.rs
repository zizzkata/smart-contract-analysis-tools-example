use std::process::Command;
use std::str;

pub fn run_smtchecker(prj_root_path: &str, contract_name: &str) -> String {
    // TODO: see if sudo can be removed
    let command = format!(
        "sudo ./security-scans/SMTChecker/run-SMTChecker.sh {} {}",
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
