Velexi Template: DVC Dataset Repository (v0.1.0)
================================================

___Authors___  
Kevin T. Chu `<kevin@velexi.com>`

------------------------------------------------------------------------------

Table of Contents
-----------------

1. [Overview][#1]

    1.1. [Software Dependencies][#1.1]

    1.2. [Package Contents][#1.2]

    1.3. [License][#1.3]

    1.4. [Supported DVC Remote Storage Providers][#1.4]

2. [Getting Started][#2]

    2.1. [Setting Up the Dataset Repository][#2.1]

    2.2. [Example and Template Files][#2.2]

3. [Usage][#3]

    3.1. [Conventions][#3.1]

    3.2. [Managing Datasets with DVC][#3.2]

4. [References][#4]

------------------------------------------------------------------------------

## 1. Overview

This repository is intended to serve as a template for dataset repositories
managed by DVC. It encourages the following dataset management practices.

* Improve the reproducibility of research analysis (including machine learning
  experiments, data science analysis, and traditional scientific and
  engineering studies) by applying version control principles to datasets.

* Facilitate efficient exploration of datasets by standardizing the directory
  structure used to organize data.

* Increase reuse of datasets across projects by decoupling datasets from data
  analysis code.

* Simplify dataset maintenance by keeping the dataset management code
  (e.g., clean up scripts) with the dataset.

### 1.1. Software Dependencies

#### Base Requirements

* Python (>=3.9)
  * `pip`
* `git`
* `awk`
* `sed`

#### Optional Software

* `direnv`: only needed if using `direnv` to manage the Python virtual
  environment for the dataset repository.

### 1.2. Package Contents

    README.md
    LICENSE
    bin/
    data/
    template-docs/

* `README.md`: this file (same as `template-docs/README-Template-Usage.md`)

* `LICENSE`: license file for this repository template

* `bin`: directory where scripts and programs for maintaining the dataset
  (e.g., scripts to download data from public websites, scripts to clean up
  data) should be placed

* `data`: directory where dataset should be placed

* `template-docs`: directory containing documentation (including a copy of
  this file) and examples for this repository template

### 1.3. License

The contents of this directory are covered under the LICENSE contained in the
top-level directory of this repository.

### 1.4. Supported DVC Remote Storage Providers

* Local file system

* Amazon S3

------------------------------------------------------------------------------

## 2. Getting Started

### 2.1. Setting Up the Dataset Repository

1. Install the required software dependencies.

2. (OPTIONAL) Set up a Python virtual environment for the dataset repository.

    * Copy `template-docs/examples/envrc.example` to the top-level directory
      and rename it to `.envrc`.

      ```
      $ cp template-docs/examples/envrc.example .envrc
      ```

    * Follow `direnv` instructions to enable `.envrc` file.

3. Prepare storage for DVC.

    * __Local__: Create directory on local file system for DVC to use for
      "remote" storage.

    * __AWS__: Create S3 bucket for DVC to use for remote storage.

4. Initialize the dataset repository.

    * Copy `template-docs/examples/config.yaml.example` to the top-level
      directory and rename it to `config.yaml`.

    * Set the parameters for the dataset repository in `config.yaml`.

    * Run `init-repo.sh`.

      ```
      $ init-repo.sh config.yaml
      ```

    * Add the auto-generated `requirements.txt` file to git repository.

      ```
      $ git add requirements.txt
      $ git commit
      ```

5. Replace the `README.md` and `LICENSE` files with dataset-specific versions.
   Exampes are available in the `template-docs/examples` directory.

### 2.2. Example and Template Files

Example and template files are indicated by the "example" and "template"
suffixes, respectively. These files are intended to simplify the set up of
the data repository. When appropriate, they should be renamed (with the
"example" or "template" suffix removed).

------------------------------------------------------------------------------

## 3. Usage

### 3.1. Conventions

#### 3.1.1. `data` directory

* All data files should be placed in the `data` directory.

* Depending on the nature of the dataset, it may be useful to organize the
  data files into sub-directories (e.g., by type of data).

#### 3.1.2. `bin` directory

* Tools (e.g., data capture and processing scripts) developed to help maintain
  the dataset should be placed in the `bin` directory.

#### 3.1.3. `README.md` file

The `README.md` file should contain

* a description of the dataset and

* instructions for tools used to create and maintain the dataset.

### 3.2. Managing Datasets with DVC

#### 3.2.1. Adding Data

1. Add data files to the `data` directory.

2. Add `data` to DVC tracking, and push the dataset to remote storage.

    ```
    $ dvc add data
    $ dvc push
    ```

3. Commit DVC-generated changes to `data.dvc` to the git repository.

    ```
    $ git commit data.dvc -m "Add initial version of dataset"
    $ git push
    ```

#### 3.2.2. Updating Data

1. Update data files in the `data` directory.

2. Update DVC tracking of `data` directory, and push the dataset to remote
   storage.

    ```
    $ dvc add data
    $ dvc push
    ```

3. Commit DVC-generated changes to `data.dvc` to the git repository.

    ```
    $ git commit data.dvc -m "Update dataset"
    $ git push
    ```

#### 3.2.3. Removing Data

1. Remove data files from the `data` directory.

2. Update DVC tracking of `data` directory, and push the dataset to remote
   storage.

    ```
    $ dvc add data
    $ dvc push
    ```

3. Commit DVC-generated changes to `data.dvc` to the git repository.

    ```
    $ git commit data.dvc -m "Remove data from dataset"
    $ git push
    ```

#### 3.2.4. Releasing an official dataset version

1. Make sure that the dataset has been updated ([Section 3.2.2][#3.2.2])

2. Update `README.md` for the dataset.

3. (RECOMMENDED) Update release notes for the dataset to include any major
   changes between the previous version of the dataset.

4. Create a tag for the release in git. In the following example, `VERSION`
   should be replaced with the version number for the release (e.g. v1.0.0).

    ```
    $ git tag VERSION_NUMBER
    $ git push --tags
    ```

5. (OPTIONAL) If the git repository for the dataset is hosted on GitHub (or
   analogous service), create a release associated with the git tag created
   in Step #4.

------------------------------------------------------------------------------

## 4. References

* [DVC Documentation][#dvc-docs]

------------------------------------------------------------------------------

[-----------------------------INTERNAL LINKS-----------------------------]: #

[#1]: #1-overview
[#1.1]: #11-software-dependencies
[#1.2]: #12-package-contents
[#1.3]: #13-license
[#1.4]: #14-supported-dvc-remote-storage-providers

[#2]: #2-getting-started
[#2.1]: #21-setting-up-the-dataset-repository
[#2.2]: #22-example-and-template-files

[#3]: #3-usage
[#3.1]: #31-conventions
[#3.2]: #32-managing-datasets-with-dvc
[#3.2.1]: #321-adding-data
[#3.2.2]: #322-updating-data
[#3.2.3]: #323-removng-data
[#3.2.4]: #324-releasing-an-official-dataset-version

[#4]: #4-references

[-----------------------------EXTERNAL LINKS-----------------------------]: #

[#dvc-docs]: https://dvc.org/doc
