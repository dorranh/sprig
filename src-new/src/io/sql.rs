use std::io::Error;

use futures::Future;
use sqlx::{Database, Pool};
use tokio::runtime::Runtime;

pub struct SyncSqlClient<DB: Database> {
    // A sqlx connection pool
    pool: Pool<DB>,

    /// A tokio runtime for executing async sqlx operations in a blocking manner
    rt: Runtime,
}

pub async fn foobar() -> () {}

impl<DB: Database> SyncSqlClient<DB> {
    // Constructs a new synchronous sqlx client
    pub fn new<F, Fut>(init_pool: F) -> Result<Self, Error>
    where
        F: FnOnce() -> Fut,
        Fut: Future<Output = Result<Pool<DB>, Error>>,
    {
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()?;
        let pool = rt.block_on(init_pool())?;
        Ok(Self { pool, rt })
    }

    // Execute the wrapped function which leverages the client's connection pool in a blocking manner
    pub fn with_pool<A, E, F, Fut>(&self, f: F) -> Result<A, E>
    where
        F: FnOnce(Pool<DB>) -> Fut,
        Fut: Future<Output = Result<A, E>>,
    {
        self.rt.block_on(async { f(self.pool.to_owned()).await })
    }
}
