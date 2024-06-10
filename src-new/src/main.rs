pub mod io;
pub mod model;

use std::fs;
use std::io::Write;
use std::path::Path;

use arrow::array::RecordBatchWriter;
use arrow::ipc::writer::StreamWriter;
use io::SprigContents;
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
    /// Get a sprig by name
    Read {
        /// The name of the Sprig to read
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

    fn list_sprigs(&self) -> Result<Sprigs, std::io::Error>;

    // TODO: We probably want to accept a BufferedWriter or something like that
    // Rather than creating inside the function
    fn read_sprig(&self, sprig: Sprig) -> Result<SprigContents, std::io::Error>;
}

impl Basket for LocalBasket {
    /*
       TODO. Still need to port the following from Python:
       - [X] list_sprigs
       - [X] read
         - [X] CSV IO + Read
         - [ ] SQL IO
       - [ ] create
    */

    // FIXME: Could really use some more friendly error messages

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

fn main() -> Result<(), std::io::Error> {
    let cli = Cli::parse();

    let basket = match cli.basket {
        Some(path) => LocalBasket { path },
        None => LocalBasket {
            path: PathBuf::from("."),
        },
    };

    match &cli.command {
        Some(Commands::Get { name }) => {
            let sprig = basket.get_sprig(name)?;
            let mut stdout = std::io::stdout();
            stdout.write_all(serde_json::to_string(&sprig)?.as_bytes())
        }
        Some(Commands::Read { name }) => {
            let sprig = basket.get_sprig(name)?;
            match basket.read_sprig(sprig)? {
                // If our contents are in arrow format, we write them directly to stdout using Arrow's IPC module
                io::SprigContents::Arrow(mut reader) => {
                    let mut writer = StreamWriter::try_new(std::io::stdout(), &reader.schema())
                        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))?;
                    reader
                        .try_fold((), |_acc, batch_read_result| match batch_read_result {
                            Ok(batch) => writer.write(&batch),
                            Err(e) => Err(e),
                        })
                        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))
                }
            }
        }
        Some(Commands::List {}) => {
            let sprigs = basket.list_sprigs()?;
            let mut stdout = std::io::stdout();
            stdout.write_all(serde_json::to_string(&sprigs)?.as_bytes())
        }
        None => Ok(()),
    }
}
