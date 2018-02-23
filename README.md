# CircuitBreakerTime

The demo for the Swift Cloud Workshop 3 talk on Circuit Breakers with Swift

![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)
[![DUB](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/eman6576/CircuitBreakerTime/blob/master/LICENSE)
[![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)]()
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

## Table of Contents

- [Background](#background)
- [Requirements](#requirements)
- [Install](#install)
- [Usage](#usage)
- [API](#api)
- [Contribute](#contribute)
- [License](#license)

## Background

This is final demo for the Swift Cloud Workshop 3 talk on Circuit Breakers with Swift. This demo contains a webserver that demonstrates how to use two different versions of a circuit breaker. They are a light weight implementation called [SGCircuitBreaker](https://github.com/eman6576/SGCircuitBreaker) and [IBM-Swift's Circuit Breaker](https://github.com/IBM-Swift/CircuitBreaker).

## Requirements

* Swift 4.0 and greater
* macOS: 10.9 and greater
* Linux
* Make build utility
* Docker

## Install

### Repo setup

In a terminal, you can clone the repo like so:

```bash
$ git clone git@github.com:eman6576/CircuitBreakerTime.git
```

then change into the directory like so:

```bash
$ cd CircuitBreakerTime
```

## Build project

To build the project and open it in Xcode, you can enter this command:

```bash
$ make all
```

To reset the build directories and rebuild, you can use:

```bash
$ make clean_all
```

## Usage

### Running The Server

The webserver can run on both macOS and Linux.

To run the webserver in macOS, use:

```bash
$ make run_local
```

To run the webserver in Linux using Docker, use:

```bash
$ make run_linux
```

### Endpoints

The base url of the webserver is `http://localhost:8090`. There are five endpoints that you can access:

These endpoints use an instance of `SGCircuitBreaker`.

* `/swiftyguerrero`
    * GET `/success`: Simulates a successful operation and notifies the client that it was intially successful.
    * GET `/success-delay`: Simulates a operation that timesout the first time and then succeds the second time.
    * GET `/failure`: Simulates a operation that failed and that would trip the circuit.

These endpoints use an instance of IBM-Swift's `CircuitBreaker`.

* `/ibm`
    * GET `/success`: Simulates a successful operation and notifies the client that it was intially successful.
    * GET `/failure`: Simulates a operation that failed and that would trip the circuit.

## Maintainers

Manny Guerrero [![Twitter Follow](https://img.shields.io/twitter/follow/SwiftyGuerrero.svg?style=social&label=Follow)](https://twitter.com/SwiftyGuerrero) [![GitHub followers](https://img.shields.io/github/followers/eman6576.svg?style=social&label=Follow)](https://github.com/eman6576)

## License

[MIT © Manny Guerrero.](https://github.com/eman6576/CircuitBreakerTime/blob/master/LICENSE)