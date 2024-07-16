//! Utilities for reading and writing the actual contents of a sprig
//!
//! TODO
//!   - [ ] Move read methods into traits
//!   - [ ] Add logic for writing out usage metadata
use std::{
    fs::File,
    io::{BufRead, BufReader, Error, ErrorKind, Seek},
    marker::PhantomData,
    path::PathBuf,
    sync::Arc,
};

use arrow::array::RecordBatchReader;
use arrow_csv::{reader::Format, ReaderBuilder};

use crate::model::{
    Format::Csv, Format::Sql, LocalStorageConfig, Sprig, Storage::Local, Structure::Blob,
    Structure::Columns, Structure::Rows,
};

/// The actual contents of a sprig (i.e. the data). Can have different types
/// depending on the structure of the sprig.
pub enum SprigContents {
    /// Data in Arrow format
    Arrow(Box<dyn RecordBatchReader>), // FIXME: This should contain the arrow type instead
}

/// Helper function to resolve a path relative to the basket path
fn resolve_path(basket_path: PathBuf, data_file_path: PathBuf) -> Result<PathBuf, Error> {
    let full_unresolved_path = basket_path.join(data_file_path);
    full_unresolved_path.canonicalize()
}

// Goals: Make it pretty easy to add in a new FORMAT or STORAGE type. Basically create the type and then implement
// a Reader and a Writer trait.
//
// For example, given a new Format:
//
// struct Parquet<S> {config: ParquetConfig, storage: S}
//
// You would then do something like:
//
//
// impl TableReader<STORAGE> for Parquet, e.g. impl TableReader<Local> for Parquet<Local> {config: ParquetConfig, storage: Local}
//
//
//

trait TableReader {
    type S;
    fn read(&self, storage: Self::S) -> Result<Box<dyn RecordBatchReader>, std::io::Error>;
}

struct ParquetConfig {}

struct Parquet<S> {
    config: ParquetConfig,
    storage: S,
}

enum Table<S> {
    Parquet(Parquet<S>),
    // And so on
}

// struct Table<S, F: TableReader<S>> {
//     sprig: BetterTypedSprig<F>,
// }

enum NewStructureEvenBetter {
    Table,
    Blob,
}

impl TableReader for Parquet<LocalStorageConfig> {
    type S = LocalStorageConfig;
    fn read(
        &self,
        storage: LocalStorageConfig,
    ) -> Result<Box<dyn RecordBatchReader>, std::io::Error> {
        unimplemented!();
    }
}

// Other(PhantomData<S>),

enum Source {
    Table,
    Blob,
}

struct BetterTypedSprig<F> {
    source: F,
}

// Implied Structure
fn read_table<F>(sprig: &BetterTypedSprig<F>) -> Result<Box<dyn RecordBatchReader>, std::io::Error>
where
    F: TableReader,
{
    unimplemented!()
}

/*
 *
 * In short, my problem is that given a sprig file, we need to know how to dispatch to a read method.
 *   In theory we can either specify the read method at runtime (e.g. pass a --format=table flag) or read the format as a part of the sprig's configuration,
 *     However I seem to be running into issues properly framing this problem, perhaps due to the format appearing in the Sprig's type signature.
 *
 *
 */

// Serde constraint table to those with a read_table method

// struct Table<T: TableReader> {
//     source: T,
// }

struct SomeBigBlob<B> {
    source: B,
}

enum DataSource<T: TableReader, B> {
    Table(T),
    Blob(B),
}

/*
enum Source {
    TableReader
}

# foo.sprig.yaml

source:
    table: # Must implement table reader
        parquet:
            config: {}
            storage:
                local:
                    path: foo.parquet
    blob: # Must implement blob reader
*/

// Faced with a design choice here. Do we push the structure down into the format type or do we accept the structure separately
// and use it to dispatch the appropriate read method.
//   If its pushed into the format it does not need to be specified separately but means each format may only be read in one way.

// Brainstorming:
// For a generic read, need to infer structure from format...
//   Basically given a path, deserialize to a Sprig. Then given the type you need to
//     dispatch a different read method.
//
// Then, when we deserialize a sprig, we need to be able to constraint the return type so that we can pass it to our read method.
//    Perhaps there is some way to define a HasRead or similar trait which can help with this. Otherwise we need to wrap the Sprig in the structure
//    that we want to read it as. e.g. Table<Sprig<Csv, LocalStorage>> vs Blob<Sprig<Csv, Localstorage>>, etc.
//    An alternative would be to wrap the inner type of the Sprig with the Structure. That might be a bit more logical:
//       Sprig<Table<Csv, LocalStorage>> vs Sprig<Blob<Binary, LocalStorage>> vs Sprig<Image<Png, S3Storage>>

fn foo() -> () {
    let stg: LocalStorageConfig = LocalStorageConfig {
        path: "data.parquet".to_string(),
    };
    let fmt = Parquet {
        config: ParquetConfig {},
        storage: stg,
    };
    let better_sprig = BetterTypedSprig { source: fmt };
    let x = read_table(&better_sprig);
    ()
}

// fn read_rows(Sprig<F, S> where there exists a RowReader <F,S> impl)
// fn read(Sprig) where there exists a Reader<Structure, Sprig, S> implementation or something like that.
// I am also not sure whether we even need the structure property in the Sprig itself since currently each Format as
// an implicit structure...

/// Read a sprig made up of rows
fn read_rows(
    sprig: &Sprig,
    basket_path: PathBuf,
    start: i64,
    stop: Option<i64>,
) -> Result<Box<dyn RecordBatchReader>, std::io::Error> {
    match sprig.format {
        Csv => match &sprig.storage {
            Local(LocalStorageConfig { path }) => {
                let format = Format::default();
                let data_file_path = resolve_path(basket_path, PathBuf::from(path))?;
                // Create a reader for inferring the schema, skipping header row
                let mut reader = BufReader::new(File::open(data_file_path)?);
                // Seek ahead just past the first newline, if it exists.
                reader.read_until(b'\n', &mut Vec::new())?;
                // Note the position so we can rewind to it
                let start_offset = reader.stream_position()?;

                // Infer the file's schema
                let (schema, n_records) = format
                    .infer_schema(&mut reader, None)
                    .map_err(|e| Error::new(ErrorKind::Other, e))?;

                if n_records == 0 {
                    return Err(Error::new(
                        ErrorKind::Other,
                        "No records found in the input file",
                    ));
                }
                let start_usize =
                    usize::try_from(start).map_err(|e| Error::new(ErrorKind::Other, e))?;
                // Note: using the value returned by infer_schema is a bit sketchy here since it assumes that infer_schema has scanned
                // the entire input file. If a max_records is provided to it then the implementation below will be incorrect.
                let stop_usize = match stop {
                    Some(s) => usize::try_from(s).map_err(|e| Error::new(ErrorKind::Other, e))?,
                    None => n_records,
                };

                // Rewind our buffer to the first line of data
                reader.seek(std::io::SeekFrom::Start(start_offset))?;

                let csv = ReaderBuilder::new(Arc::new(schema))
                    .with_bounds(start_usize, stop_usize)
                    .build(reader)
                    .unwrap();

                Ok(Box::new(csv))
            }
            s => Err(Error::new(
                ErrorKind::Other,
                format!(
                    "The provided storage type is not supported for the CSV format: {:?}",
                    s
                ),
            )),
        },
        Sql => {
            unimplemented!("Support for SQL formats has not yet been implemented.")
        }
    }
}

/// Read the contents of a sprig
pub fn read(sprig: &Sprig, basket_path: PathBuf) -> Result<SprigContents, std::io::Error> {
    match sprig.structure {
        Rows => read_rows(
            sprig,
            basket_path,
            sprig.read_config.start,
            sprig.read_config.stop,
        )
        .map(SprigContents::Arrow),
        Columns => {
            unimplemented!("Support for reading columnar data has not yet been implemented.")
        }
        Blob => {
            unimplemented!(
                "Support for reading arbitrary binary data has not yet been implemented."
            )
        }
    }
}
