use std::{
    fs::File,
    io::{BufReader, Error, ErrorKind},
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

// FIXME: Add methods for writing out usage metadata

// TODO: It might be cleaner to move these read methods into traits
fn read_rows(
    sprig: &Sprig,
    start: i64,
    stop: Option<i64>,
) -> Result<Box<dyn RecordBatchReader>, std::io::Error> {
    match sprig.format {
        Csv => match &sprig.storage {
            Local(LocalStorageConfig { path }) => {
                let format = Format::default();
                let (schema, n_records) = format
                    .infer_schema(BufReader::new(File::open(path)?), None)
                    .map_err(|e| Error::new(ErrorKind::Other, e))?;

                let start_usize =
                    usize::try_from(start).map_err(|e| Error::new(ErrorKind::Other, e))?;
                // Note: using the value returned by infer_schema is a bit sketchy here since it assumes that infer_schema has scanned
                // the entire input file. If a max_records is provided to it then the implementation below will be incorrect.
                let stop_usize = match stop {
                    Some(s) => usize::try_from(s).map_err(|e| Error::new(ErrorKind::Other, e))?,
                    None => n_records,
                };

                let csv = ReaderBuilder::new(Arc::new(schema))
                    .with_bounds(start_usize, stop_usize)
                    .build(BufReader::new(File::open(path)?))
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

pub fn read(sprig: &Sprig) -> Result<SprigContents, std::io::Error> {
    match sprig.structure {
        Rows => read_rows(sprig, sprig.read_config.start, sprig.read_config.stop)
            .map(|r| SprigContents::Arrow(r)),
        Columns => {
            unimplemented!()
        }
        Blob => {
            unimplemented!()
        }
    }
}
