# Design

## Background

Software applications and the services which provide them with data are
traditionally separated logically, with the software application containing the
logic for IO and the database, etc. being only concerned with storing data. This
is a good and logical separation of concerns. Beyond these two key types of
entities are metastores which are services which provide an access layer for
data stores (especially unstructured object stores). Metastores help solve
problems such as keeping track of what data is available in the underlying data
store and can be used for things like access control as well.

The idea behind this project is to explore the question: what if a data access
layer existed which knew more about the internals of the applications which
access it? How much information would that layer need to have in order to be
able to implement some useful features beyond what a normal metastore can do?

## Vision

As of the writing of this document, this problem space seems to be largely
unexplored. I can imagine why, as the problem space is huge - how does one write
an application which is capable of understanding the internals of applications
which could be written in a number of different programming languages,
frameworks, etc? Conversely, with a bit of extra knowledge you could implement a
number of interesting features. Let's think about a few of them.

### 1. Tracking of data dependencies

One of the first benefits such a system could provide is the ability to track
the IO of a given application (assuming that all IO happens via our system).
That already provides a huge benefit in that we can now declare these
dependencies and include them with our application. This allows us to at a
minimum declare to users what data our application will use and allow them to
make sure that they are able to access that data, etc.

### 2. Smarter caching / fetching

Related to (1), since the system is aware of the data a program will use, data
can be fetched and cached in an optimal (and potentially configurable) way
rather than relying on the application itself to implement this logic. One can
envision scenarios where different caching strategies are preferred
(aggressively fetch when the program starts, fetch lazily, fetch only up to X
amount of data at a time to avoid excessive disk usage, etc.)

### 3. Workflow generation

In cases where you have a series of programs which consume overlapping data from
the system one could envision a feature where you automatically declare the
dependency graph of these programs for use with a workflow / automation tool.
The system could potentially even bundle the applications required by the
workflow if the applications' languages support that.

### 4. Visualization / analytics

Another advantage to knowing where data is being used is that the system has an
overview of the flow of data across all applications. This is potentially useful
for managing larger teams / projects where it can be hard to track what
applications have been developed and what data they use (e.g. data science /
analysis scripts). In this case the system might need to run remotely or in some
kind of join local-remote set-up so that metadata can be centrally tracked /
shared.

## Technical Spec

> This is a work in progress

Now that we are convinced that such a system would be useful, let's explore the
possible design(s).

One of the most critical aspects of such a system is that it needs to have a
good UX and integrate well with the native ways people use IO in their
respective languages and frameworks. This is a challenging requirement since the
design space is so large (especially if we want to target multiple languages). A
possible way to handle this is to split up client logic from the core of the
system, placing the burden on clients to implement easy to use interfaces which
integrate well with their respective languages. These clients will then
communicate with the core system via a protocol which requires clients to
specify all key metadata we need for tracking data usage. This protocol would
likely need to be aware of the client programming language since the information
required to identify call sites varies between languages. Since the exchange of
data is largely a request-response operation, I would propose an RPC as the
basis of this protocol. The RPC protocol will need to support streaming
responses since datasets can be large, and as such I would suggest gRPC as a
good candidate.

The core system would then primarily serve to 1. track requests for data and 2.
fulfill those requests by proxing underlying data stores. This is actually a
pretty standard looking application. Most of the tricky logic lies in the
protocol and client implementations.

Finally, for implementing some of the fancy features above some logic would need
to exist which is capable of taking the metadata stored in the core system and
1.) exporting it for distributing with the applications and possibly 2.)
attempting to bundle or applications for use with workflow systems. (2) may need
to be implemented by a separate application.
