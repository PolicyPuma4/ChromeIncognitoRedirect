extern crate winres;

fn main() {
    if cfg!(target_os = "windows") {
        let mut res = winres::WindowsResource::new();
        res.set_icon("chrome_IDR_X003_INCOGNITO.ico");
        res.compile().unwrap();
    }
}
