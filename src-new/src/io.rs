pub mod sql;

use std::{
    fs::File,
    io::{BufRead, BufReader, Cursor, Error, ErrorKind, Seek},
    path::{Path, PathBuf},
    sync::Arc,
};

use arrow::{
    array::{ArrayRef, Int32Array, RecordBatch, RecordBatchReader, StringArray},
    error::ArrowError,
};
use arrow_csv::{reader::Format, ReaderBuilder};

use crate::model::{
    Format::Csv, Format::Sql, LocalStorageConfig, Sprig, Storage::Local, Structure::Blob,
    Structure::Columns, Structure::Rows,
};
pub enum SprigContents {
    Arrow(Box<dyn RecordBatchReader>), // FIXME: This should contain the arrow type instead
}

fn resolve_path(basket_path: PathBuf, data_file_path: PathBuf) -> Result<PathBuf, Error> {
    let full_unresolved_path = basket_path.join(data_file_path);
    full_unresolved_path.canonicalize()
}

// FIXME: Add methods for writing out usage metadata

// TODO: It might be cleaner to move these read methods into traits
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

                // DEBUGGING
                // reader.lines().for_each(|l| println!("{:?}", l));
                // reader.seek(std::io::SeekFrom::Start(start_offset))?;

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
            _ => {
                // TODO: Return a nice error here
                unimplemented!()
            }
        },
        Sql => {
            unimplemented!()
        }
    }
}

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
            unimplemented!()
        }
        Blob => {
            unimplemented!()
        }
    }
}
