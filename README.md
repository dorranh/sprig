# sprig

Sprig is a tool for managing the data that goes into your projects in a
_declarative_ way. It is primarily aimed at data analysis and machine learning
workflows, but you might find that it is quite handy in other settings as well!

> sprig is currently in an early prototype state. Please feel free to [open an
> issue](https://github.com/dorranh/sprig/issues/new) if you have a question,
> idea, or feature request!

## Installation

Sprig has not yet been released, so you will need to build / install it manually
to try it out. See the [Development](#development) section for more details.

## Elevator pitch

When analyzing data or building a model, one often ends up following a fairly
common workflow, the first step being to gather and wrangle your data. This
might involve running some SQL queries, fetching data from your data lake, or
simply downloading a CSV file. Once you've gotten your data you can dive into
your analysis, whether that means doing a bit of Python scripting or simply
using Excel. You generate a few reports, close your laptop, and call it a day.
Time to celebrate! 🍻

But wait, a month later you need to re-run your analysis. What were those files
that went into it again?

Now your colleague has asked for you to share your work so they can build on top
of it, but they haven't got a clue as to what data your Jupyter notebook reads.
After a long Slack exchange and digging into your code, it looks like it reads
`./my-great-dataset-v1.csv`, but neither of you can remember where that file
originates from or can be found now.

Sprig is a lightweight tool which aims to alleviate some of these headaches. You
use sprig as a layer for accessing your data, whether that be CSV files on a
network share, delta files in your company's data lake, or some database query
you've concocted. When you access your data using sprig, it automatically keeps
track of what data you access, recording this information locally in a format
which is human readable and can also be checked into version control if desired.

Now the data you consume is declared right next to your code. The next time you
need to re-run or share your analysis, sprig will be there to help you get
things running.

## Usage

Sprig aims to integrate with a variety of tools commonly used for analyzing and
processing data. Currently it only supports Python, though R and Excel clients
are on the roadmap.

### Basics

#### Importing and accessing data

The key type you interact with sprig is (unsurprisingly) called `Sprig`. A sprig
can be though of as a *reference* to a dataset. This means that the sprig
specifies the details of your upstream data sources while not containing the
data itself. Sprigs are stored in your project in `.sprig` files and may be
re-used across different scripts, analyses, etc.

If you are just getting started, you will want to create a Sprig from some
existing data. To do this you can either use the Sprig CLI or directly in your
language of choice following the instructions below.

If you already have sprigs in your project, you can directly start consuming
them without any addititional configuration. Simply follow the language-specific
instructions for loading the Sprig in your code outlined below.

#### Writing data

Sprig also supports writing out intermediate datasets which you generate during
your analyses. This allows you to build out more complex data analysis pipelines
and share your intermediate results for consumption in other projects as well.

#### Examples

A variety of example projects using sprig can be found in the [`examples`](./examples/) directory.

### Python

You use a `Basket` for interacting with sprig. For example, to list sprigs
already available in your project:

```python
from sprig.client.basket import LocalBasket

basket = LocalBasket()

print(basket.list_sprigs())
```

You can also get a `Sprig` by name using a `Basket`. The `Sprig` class provides
helper methods for integrating with your data analaysis library of choice (e.g.
`pandas`)

```python
sprig = basket.get_sprig(name="my-sprig")

df = basket.read_sprig(sprig.name).to_pandas()

df.head()
```

## Development

This repository is structured as a monorepo. Language-specific clients can be
found in [`./clients`](./clients) and the Sprig CLI and back-end can be found in
[`./src`](./src).

This project uses `Nix` for providing dev dependencies and related tooling and
`Just` for streamlining building the project.

You can enter the development shell using the `nix develop` command or
automatically using the provided `direnv` `.envrc` file if you have `direnv`
installed.

Once in a shell, install 3rd-party dependencies with

```sh
just install
```

Then build and lint the project with:

```
just
```

## Architecture

**TODO**
