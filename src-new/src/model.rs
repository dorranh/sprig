use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Structure {
    Rows,
    Columns,
    Blob,
}

#[derive(Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Format {
    Csv,
    Sql,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LocalStorageConfig {
    path: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DatabaseStorageConfig {
    connection_string: String, // FIXME: Need to handle secrets, etc properly.
    query: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RowConfig {
    start: i64,
    stop: Option<i64>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Sprig {
    id: Uuid,
    name: String,
    storage: Storage,
    structure: Structure,
    format: Format,
    read_config: RowConfig, // TODO: Add other config here
}

#[derive(Debug, Serialize, Deserialize)]
// #[serde(rename_all = "lowercase")]
#[serde(untagged)]
pub enum Storage {
    Local(LocalStorageConfig),
    Database(DatabaseStorageConfig),
}
