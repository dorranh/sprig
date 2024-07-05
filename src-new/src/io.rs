//! Utilities for reading and writing the actual contents of a sprig
//!
//! TODO
//!   - [ ] Move read methods into traits
//!   - [ ] Add logic for writing out usage metadata
use std::{
    fs::File,
    io::{BufRead, BufReader, Error, ErrorKind, Seek},
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
            s => {
                return Err(Error::new(
                    ErrorKind::Other,
                    format!(
                        "The provided storage type is not supported for the CSV format: {:?}",
                        s
                    ),
                ));
            }
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
        .map(|r| SprigContents::Arrow(r)),
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
