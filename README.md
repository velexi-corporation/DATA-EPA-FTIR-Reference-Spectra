EPA FTIR Reference Spectra
==========================

___Authors___  
Kevin Chu `<kevin@velexi.com>`

------------------------------------------------------------------------------

Contents
--------

1. [Overview][#1]

    1.1. [Dataset Contents][#1.1]

    1.2. [License][#1.2]

2. [Tools][#2]

    2.1. [Software Dependencies][#2.1]

    2.2. [Usage][#2.2]

3. [Known Issues][#3]

------------------------------------------------------------------------------

## 1. Overview

This dataset contains [FTIR Reference Spectra][epa-ftir-reference-spectra]
published by the EPA. The dataset consists of a collection of spectra for
organic compounds.

### 1.1. Dataset Contents

The `data` directory contains the following files:

* `metadata.csv`: a list of spectra, basic information about the sample
  (e.g., compound, pathlength, concentration), the name of the spectra file,
  and the URL of the raw data source

* `*.spc` files: individual spectra files stored [SPC format][wikipedia-spc]

    * Spectra file are named according to the convention:

      `{cas_number}--{compound_name}--{record_id}.spc`

* `VERSION`: text file containing current version of dataset

### 1.2. License

* The copyright and license information for the code included with this
  dataset repository are covered by the LICENSE file.

* The spectra dataset is published EPA and does not appear to have any
  official licensing terms.

------------------------------------------------------------------------------

## 2. Tools

* `get-data`: script to download all spectra data files from the EPA website

### 2.1. Software Dependencies

#### Base Requirements

* Python (>=3.9)

#### Python Packages

See the `requirements.txt` file.

### 2.2. Usage

#### Downloading Spectra Data

To download the current set of spectra data from the EPA website, run the
`get-data` script without any arguments.

```
$ get-data
```

------------------------------------------------------------------------------

## 3. Known Issues

* List of known issues with the dataset.

------------------------------------------------------------------------------

[-----------------------------INTERNAL LINKS-----------------------------]: #

[#1]: #1-overview
[#1.1]: #11-dataset-contents
[#1.2]: #12-license

[#2]: #2-tools
[#2.1]: #21-software-dependencies
[#2.2]: #22-usage

[#3]: #3-known-issues

[-----------------------------EXTERNAL LINKS-----------------------------]: #

[epa-ftir-reference-spectra]: https://www3.epa.gov/ttn/emc/ftir/refnam.html

[wikipedia-spc]: https://en.wikipedia.org/wiki/SPC_file_format
