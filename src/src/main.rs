pub mod basket;
pub mod io;
pub mod model;

use std::io::Write;

use arrow::ipc::writer::StreamWriter;
use basket::Basket;
use basket::LocalBasket;

use std::path::PathBuf;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(version, about, long_about = None)]
#[command(arg_required_else_help(true))]
pub(crate) struct Cli {
    /// Connect to a specific local basket. Defaults to the current working directory.
    #[arg(short, long, value_name = "BASKET")]
    basket: Option<PathBuf>,

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
    /// Read the contents of a sprig, writing them to stdout.
    /// Note that the data you get back will depend on the structure of the sprig.
    /// Rows will be returned as a stream of Arrow RecordBatches.
    Read {
        /// The name of the Sprig to read
        #[arg(long)]
        name: String,
    },
    /// List the names of the sprigs in the current basket
    List {},
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
