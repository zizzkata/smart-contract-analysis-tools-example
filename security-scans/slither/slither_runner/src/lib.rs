//use std::process::Command;

pub fn run_slither(prj_root_path: &str, contract_name: &str) {
    println!("prj_root_path: {}", prj_root_path);
    println!("contract_name: {}", contract_name);

    // let result = Command::new("sh")
    //     .arg("-c")
    //     .arg("echo hello")
    //     .output()
    //     .expect("failed to execute process")
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
