//! Utilities for working with baskets (i.e. repos for sprigs)
use std::fs;
use std::path::Path;

use io::SprigContents;

use std::path::PathBuf;

use crate::io;
use crate::model::{Sprig, Sprigs};

/// A basket acts as a repository for sprigs, providing a methods for interacting with them.
pub trait Basket {
    fn get_sprig(&self, name: &str) -> Result<Sprig, std::io::Error>;

    fn list_sprigs(&self) -> Result<Sprigs, std::io::Error>;

    // TODO: We probably want to accept a BufferedWriter or something like that
    // Rather than creating inside the function
    fn read_sprig(&self, sprig: Sprig) -> Result<SprigContents, std::io::Error>;
}

/// A basket which resides on the local filesystem
pub struct LocalBasket {
    pub path: PathBuf,
}

impl Basket for LocalBasket {
    // FIXME: Could really use more friendly error messages

    fn read_sprig(&self, sprig: Sprig) -> Result<SprigContents, std::io::Error> {
        io::read(&sprig, self.path.to_owned())
    }

    fn get_sprig(&self, name: &str) -> Result<Sprig, std::io::Error> {
        let sprig_file = self.path.join(name).with_extension("sprig");
        let raw_sprig_data: String = fs::read_to_string(sprig_file)?;
        let sprig: Sprig = serde_yaml::from_str(&raw_sprig_data)
            .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))?;
        Ok(sprig)
    }

    fn list_sprigs(&self) -> Result<Sprigs, std::io::Error> {
        {
            let sprig_files = Path::read_dir(&self.path)?;
            let names = sprig_files
                .filter_map(|x| x.ok())
                .map(|f| f.path())
                .filter_map(|p| {
                    if p.extension().map_or(false, |ext| ext == "sprig") {
                        // Get the file stem, doing a bit of type wrangling along the way
                        p.file_stem()
                            .map(|os_str| os_str.to_str().map(|s| s.to_owned()))
                    } else {
                        None
                    }
                })
                .flatten()
                .collect();
            Ok(Sprigs { sprigs: names })
        }
    }
}
