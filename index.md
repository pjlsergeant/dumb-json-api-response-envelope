# Dumb JSON API Response Envelope

_v0.0.1_

Dumb JSON API Response Envelope (DJARI) is a very, very simple document format
for JSON API response documents, inspired by _Self describing JSONs_[^1] + and
_JSON:API_[^2].

The goals are:

* It's easy to see which API produced a document
* It's easy to see which version of an API produced a document
* Errors are first-class citizens
* Transport-agnostic

HTTP headers and the like are outside of scope, as they're a description of the
_transport_ rather than the _payload_.

[^1]: https://docs.snowplowanalytics.com/docs/pipeline-components-and-applications/iglu/common-architecture/self-describing-jsons/
[^2]: https://jsonapi.org

## Synopsis

There are two types of DJARI documents. Those that describe successful API
responses:

```
{
    "meta": {
        "version": "0.0.1",
        "from"   : "bar/baz/whatever"
        "schema" : "https://example.com/schemas/address",
    }
    "data"  : { data conforming to the schema, if you specified one }
}
```

and those that describe errors:

```
{
    "meta": {
        "version": "0.0.1",
        "from"   : "bar/baz/whatever"
        "schema" : "https://example.com/schemas/address",
    }
    "error": {
        "title"      : "Upstream failure",
        "code"       : "NOUPSTREAM",
        "detail"     : "Upstream server gave 500 error",
        "id"         : "5a021a6b-199f-43af-8f61-d7497e333e3a",
    }
}
```

**Every document has exactly two top-level members, `meta` and only one of
`data` and `errors`.**

### `meta`

`version` *required*, [SemVer](https://semver.org); It describes the version of
the API that produced this document

`from` *required*, string; description of where this document came from. Format
is whatever's most useful to your organization, with some ideas on format below

`schema` *optional*, schema identifier; *Iff* it's included, then the contents
of `data` should conform to the schema, if it exists

### `data`

Free-form, but if you've included `meta/schema`, then it should conform to that
schema.

### `error`

An object, with the following members:

`title` *required*, string; short, human-readable summary of the error

`detail` *optional*, string; human-readable explanation specific to _this_
occurrence of the problem. If `title` says there are no upstream servers, then
`detail` might tell you which

`code` *optional*, string; application-specific error code, as a string value.
Some people like to use HTTP error codes, or this might be a canonical version
of `title` that hasn't been localized. This is meant to be matched by a machine
or by grep

`id` *optional*, string; a unique identifier for this particular occurence of
the problem, which can be cross-referenced against other logs

`trace` *optional*, anything; literally anything else you think you might find
useful

## Discussion and Ideas

### Ideas for `meta/from`

* _Self describing JSONs_[^1] has some interesting ideas for its `schema` key
* Or something like `yourorg/api-name/api-method#http-method`
* It'd be useful for this to be both human readable, but also easily filterable
if you end up with a directory of documents

### Single `error`

JSON:API specifies an array of error objects, but how often are these really
being machine parsed in order? Use the primary error, and put anything else
intereting into `trace`.

### A quick note on APIs over HTTP

This format is completely agnostic to the transport layer, but it seems likely
that it'll be HTTP. The author's recommendations for using this with HTTP are:

* Requests should be `POST`
* Content-type should be `application/json`
* Almost every HTTP status code in response should be `200`:

HTTP status codes describe the status of an HTTP transaction. Any successful
HTTP call that the server was able to put a well-formed response to should get
a `200 OK` response: a `404` means the API wasn't found. A `401` meant the API
couldn't be authenticated to. If the API was invoked, understood the request,
and was able to provide a well-formed response to it, it should get a `200`
code.

## Changes

v0.0.1 - 2021-08-17 first draft
