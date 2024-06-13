pub mod sql;

use std::{
    fs::File,
    io::{BufRead, BufReader, Cursor, Error, ErrorKind, Seek},
    path::{Path, PathBuf},
    pin::Pin,
    sync::Arc,
};

use arrow::{
    array::{
        ArrayRef, Int32Array, RecordBatch, RecordBatchIterator, RecordBatchReader, StringArray,
    },
    error::ArrowError,
};
use arrow_csv::{reader::Format, ReaderBuilder};
use futures::{Future, TryFutureExt};
use sql::SyncSqlClient;
use sqlx::{
    database::HasArguments, sqlite::SqliteRow, Database, Executor, IntoArguments, Pool, Row,
    Sqlite, SqlitePool,
};

use crate::model::{
    DatabaseStorageConfig,
    Format::{Csv, Sql},
    LocalStorageConfig, Sprig,
    Storage::Local,
    Structure::{Blob, Columns, Rows},
};
pub enum SprigContents {
    Arrow(Box<dyn RecordBatchReader>), // FIXME: This should contain the arrow type instead
}

fn resolve_path(basket_path: PathBuf, data_file_path: PathBuf) -> Result<PathBuf, Error> {
    let full_unresolved_path = basket_path.join(data_file_path);
    full_unresolved_path.canonicalize()
}

fn read_sql<DB: Database>(
    sprig: &Sprig,
    basket_path: PathBuf,
    client: sql::SyncSqlClient<DB>,
    start: i64,
    stop: Option<i64>,
) -> Result<Box<dyn RecordBatchReader>, std::io::Error> {
    unimplemented!()
}

fn row_to_record<R, DB>(row: R) -> Result<RecordBatch, std::io::Error>
where
    DB: Database,
    R: sqlx::Row<Database = DB>,
{
    unimplemented!()
}

// FIXME: Add methods for writing out usage metadata

// fn create_async_function<'a>(
//     pool: SqlitePool,
//     query: &'a str,
// ) -> Box<dyn Fn() -> Pin<Box<dyn Future<Output = Result<(), sqlx::Error>> + Send + 'a>> + 'a> {
//     Box::new(move || {
//         let pool_clone = pool.clone();
//         let query_clone = query.to_string();
//         Box::pin(async move {
//             let _ = sqlx::query(&query_clone)
//                 .execute(&pool_clone)
//                 .await?;
//             Ok(())
//         })
//     })}

// async fn query_rows_untyped(
//     pool: Pool<sqlx::Sqlite>,
//     query: &str,
// ) -> Result<SqliteRow, sqlx::Error> {
//     move |pool| async { sqlx::query(query).fetch_one(&pool).await }
// }

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
        Sql => match &sprig.storage {
            crate::model::Storage::Database(DatabaseStorageConfig {
                connection_string,
                query,
            }) => {
                // Create the client
                let client = SyncSqlClient::new(|| {
                    SqlitePool::connect(&connection_string)
                        .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))
                })?;

                // Run the query
                let query_result = client
                    .with_pool(|p| async move { sqlx::query(query).fetch_one(&p).await })
                    .unwrap(); // FIXME: Unsafe unwrap

                // Map it into our Arrow model
                let record = row_to_record(query_result);
                let unwrapped_record = record.unwrap();
                let schema = unwrapped_record.to_owned().schema();
                let batches = vec![unwrapped_record];
                let reader = RecordBatchIterator::new(batches.into_iter().map(Ok), schema);
                Ok(Box::new(reader))
            }
            _ => unimplemented!(),
        },
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
