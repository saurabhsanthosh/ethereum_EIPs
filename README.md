# Ethereum EIPs


Welcome to my Ethereum EIP project. This is a personal collection of EIP drafts


## Requirements

This project has the following requirements:

- [Node.js](https://nodejs.org/) 12.x or later
- [NPM](https://docs.npmjs.com/cli/) version 5.2 or later
- [Truffle](https://www.trufflesuite.com/docs/truffle/getting-started/installation)
- [Ganache](https://www.trufflesuite.com/ganache)
- Windows, Linux or MacOS

## Installation

> Install Node
```bash
$ brew install node
```

> Install Truffle
```bash
$ npm install -g truffle
```

> Install Ganache CLI
```bash
$ npm install -g ganache-cli
```

## Setup

### Running Truffle Commands

```bash
$ truffle compile --all
```

```bash
$ truffle test
```

```bash
$ truffle test ./test/erc27.js
```

### Running Truffle Console

```bash
$ truffle console
```

```bash
$ truffle develop
```

### Deploying the contracts

```bash
$ truffle migrate
```

```bash
$ truffle migrate -f 1 --to 1
```
