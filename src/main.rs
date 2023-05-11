#![windows_subsystem = "windows"]

use std::env;
use std::process::Command;
use winreg::enums::HKEY_CURRENT_USER;
use winreg::enums::KEY_READ;
use winreg::RegKey;

fn main() {
    let key = RegKey::predef(HKEY_CURRENT_USER)
        .open_subkey_with_flags(
            r"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe",
            KEY_READ,
        )
        .unwrap();
    let path: String = key.get_value("").unwrap();

    let args: Vec<String> = env::args().skip(1).collect();
    Command::new(path).args(args).spawn().unwrap();
}
