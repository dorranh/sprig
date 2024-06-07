pub mod model;

use std::fs;
use std::io;

use model::Sprig;

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
}

pub struct LocalBasket {
    path: PathBuf,
}

pub trait Basket {
    fn get_sprig(&self, name: &str) -> Result<Sprig, std::io::Error>;
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
}

fn main() -> std::io::Result<()> {
    let cli = Cli::parse();

    let basket = match cli.basket {
        Some(path) => LocalBasket { path },
        None => LocalBasket {
            path: PathBuf::from("."),
        },
    };

    match &cli.command {
        Some(Commands::Get { name }) => {
            let sprig = basket.get_sprig(name);
            println!("{:?}", sprig);
        }
        None => {}
    }
    Ok(())
}
