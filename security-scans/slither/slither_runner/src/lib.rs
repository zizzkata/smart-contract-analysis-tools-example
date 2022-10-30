use std::process::Command;
use std::str;

pub fn run_slither(prj_root_path: &str, contract_name: &str) -> String {

    let command = format!("sudo ./security-scans/slither/run-slither.sh {} {}", prj_root_path, contract_name);

    // ./security-scans/slither/run-slither.sh ${PWD}
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


pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
