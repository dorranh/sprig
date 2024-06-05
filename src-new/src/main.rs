// use crate::model::{LocalStorageConfig, Sprig, Structure};
// use uuid::Uuid;
pub mod model;
use std::fs;
use std::io;

use model::Sprig;

fn main() -> std::io::Result<()> {
    let raw_sprig_data: String = fs::read_to_string("./example.sprig")?;
    let sprig: Sprig = serde_yaml::from_str(&raw_sprig_data)
        .map_err(|e| io::Error::new(io::ErrorKind::Other, e))?;

    println!("{}", raw_sprig_data);
    println!("{:?}", sprig);
    Ok(())
}
