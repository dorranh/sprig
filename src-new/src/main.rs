pub mod model;

use std::fs;
use std::io;
use std::path::Path;

use model::Sprig;
use model::Sprigs;

use std::path::PathBuf;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(version, about, long_about = None)]
#[command(arg_required_else_help(true))]
pub(crate) struct Cli {
    /// Connect to a specific local basket. Defaults to the current working directory.
    #[arg(short, long, value_name = "BASKET")]
    basket: Option<PathBuf>,

    // /// Turn debugging information on
    // #[arg(short, long, action = clap::ArgAction::Count)]
    // debug: u8,
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Get a sprig by name
    Get {
        /// The name of the Sprig to get
        #[arg(long)]
        name: String,
    },
    List {},
}

pub struct LocalBasket {
    path: PathBuf,
}

pub trait Basket {
    fn get_sprig(&self, name: &str) -> Result<Sprig, std::io::Error>;

    fn list_sprigs(&self) -> Result<Vec<String>, std::io::Error>;
}

impl Basket for LocalBasket {
    /*
       TODO. Still need to port the following from Python:
       - [ ] list_sprigs
       - [ ] read
         - [ ] CSV IO + Read
         - [ ] SQL IO
       - [ ] create
    */

    // FIXME: Could really use some more friendly error messages

    fn get_sprig(&self, name: &str) -> Result<Sprig, std::io::Error> {
        let sprig_file = self.path.join(name).with_extension("sprig");
        println!("Attempting to read sprig at: {:?}", sprig_file);
        let raw_sprig_data: String = fs::read_to_string(sprig_file)?;
        let sprig: Sprig = serde_yaml::from_str(&raw_sprig_data)
            .map_err(|e| io::Error::new(io::ErrorKind::Other, e))?;
        Ok(sprig)
    }

    fn list_sprigs(&self) -> Result<Vec<String>, std::io::Error> {
        {
            let sprig_files = Path::read_dir(&self.path)?;
            let names = sprig_files
                .filter_map(|x| x.ok())
                .map(|f| f.path())
                .filter_map(|p| {
                    if p.extension().map_or(false, |ext| ext == "sprig") {
                        p.as_os_str().to_str().map(|p| p.to_owned())
                    } else {
                        None
                    }
                })
                .collect();
            Ok(names)
        }
    }
}

fn main() -> Result<(), std::io::Error> {
    let cli = Cli::parse();

    let basket = match cli.basket {
        Some(path) => LocalBasket { path },
        None => LocalBasket {
            path: PathBuf::from("."),
        },
    };

    let result: Result<String, io::Error> = match &cli.command {
        Some(Commands::Get { name }) => {
            let sprig = basket.get_sprig(name)?;
            let json = serde_json::to_string(&sprig);
            json.map_err(|e| io::Error::new(io::ErrorKind::Other, e))
        }
        Some(Commands::List {}) => {
            let sprigs = Sprigs {
                sprigs: basket.list_sprigs()?,
            };
            let json = serde_json::to_string(&sprigs);
            json.map_err(|e| io::Error::new(io::ErrorKind::Other, e))
        }
        None => Ok("".to_string()),
    };
    println!("{}", result?);
    Ok(())
}
