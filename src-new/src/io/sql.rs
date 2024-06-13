use std::io::Error;

use futures::Future;
use sqlx::{database::HasArguments, query::Query, Database, Executor, IntoArguments, Pool, Row};
use tokio::runtime::Runtime;

// enum SupportedDB {
//     Sqlite(sqlx::Sqlite),
// }

pub struct SyncSqlClient<DB: Database> {
    // A sqlx connection pool
    pool: Pool<DB>,

    /// A tokio runtime for executing async sqlx operations in a blocking manner
    rt: Runtime,
}

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

    // pub async fn create_products_table<'a, DB, E>(e: E) -> Result<(), Error>
    // where
    //     DB: Database,
    //     <DB as HasArguments<'a>>::Arguments: IntoArguments<'a, DB>,
    //     E: Executor<'a, Database = DB>,
    // {
    //     sqlx::query(include_str!(
    //         "../sql/create_products_table.sql"
    //     ))
    //     .execute(e)
    //     .await?;
    //     Ok(())
    // }

    // pub fn query<'a, E, R>(&self, query: &'a str) -> Result<R, sqlx::Error>
    // where
    //     R: sqlx::Row<Database = DB>,
    //     <DB as HasArguments<'a>>::Arguments: IntoArguments<'a, DB>,
    //     // E: Executor<'a, Database = DB>,
    //     for<'c> E: 'a + Executor<'c, Database = DB>,
    //     // for<'q> DB: HasArguments<'q>,
    //     // for<'q> <DB as HasArguments<'q>>::Arguments: IntoArguments<'q>,
    //     // F: FnOnce(Pool<DB>) -> Fut,
    //     // Fut: Future<Output = Result<A, E>>,
    // {
    //     // Query<'_, DB, <DB as HasArguments<'_>>::Arguments>
    //     self.rt.block_on(async {
    //         let foo: Query<'a, DB, R> = sqlx::query::<DB>(&query);
    //         unimplemented!()
    //     })
    // }
}
