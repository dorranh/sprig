# sprig

Sprig is a tool for managing the data that goes into your projects in a _declarative_ way. It is primarily aimed at data analysis and machine learning workflows, but you might find that it is quite handy in other settings as well!

> sprig is currently in an early prototype state. Please feel free to [open an issue](https://github.com/dorranh/sprig/issues/new) if you have a question, idea, or feature request!

## Installation / Usage

**TODO**

## Elevator pitch

When analyzing data or building a model, one often ends up following a fairly common workflow, the first step being to gather and wrangle your data. This might involve running some SQL queries, fetching data from your data lake, or simply downloading a CSV file. Once you've gotten your data you can dive into your analysis, whether that means doing a bit of Python scripting or simply using Excel. You generate a few reports, close your laptop, and call it a day. Time to celebrate! 🍻

But wait, a month later you need to re-run your analysis. What were those files that went into it again?

Now your colleague has asked for you to share your work so they can build on top of it, but they haven't got a clue as to what data your Jupyter notebook reads. After a long Slack exchange and digging into your code, it looks like it reads `./my-great-dataset-v1.csv`, but neither of you can remember where that file originates from or can be found now.

Sprig is a lightweight tool which aims to alleviate some of these headaches. You use sprig as a layer for accessing your data, whether that be CSV files on a network share, delta files in your company's data lake, or some database query you've concocted. When you access your data using sprig, it automatically keeps track of what data you access, recording this information locally in a format which is human readable and can also be checked into version control if desired.

Now the data you consume is declared right next to your code. The next time you need to re-run or share your analysis, sprig will be there to help you get things running.

## Architecture

**TODO**
