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
    pub path: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DatabaseStorageConfig {
    pub connection_string: String, // FIXME: Need to handle secrets, etc properly.
    pub query: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RowConfig {
    pub start: i64,
    pub stop: Option<i64>,
}

#[derive(Debug, Serialize, Deserialize)]
// #[serde(rename_all = "lowercase")]
#[serde(untagged)]
pub enum Storage {
    Local(LocalStorageConfig),
    Database(DatabaseStorageConfig),
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Sprig {
    pub id: Uuid,
    pub name: String,
    pub storage: Storage,
    pub structure: Structure,
    pub format: Format,
    pub read_config: RowConfig, // TODO: Add other config here
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Sprigs {
    pub sprigs: Vec<String>,
}
