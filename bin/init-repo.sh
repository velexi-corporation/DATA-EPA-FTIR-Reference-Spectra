#!/bin/bash

#-----------------------------------------------------------------------------
# Utility functions
#-----------------------------------------------------------------------------

function usage
{
    local script_name=`basename $0`

    echo "
NAME
    $script_name -- initialize DVC

SYNOPSIS
    $script_name [-h] [-q] CONFIG_FILE

DESCRIPTION
    $script_name TODO

CONFIGURATION FILE PARAMETERS

    - TODO

ARGUMENTS

    CONFIG_FILE
        configuration file to use for setup

OPTIONS
    -q
        display fewer status messages [default: display all status messages]

    -h
        print help message

REQUIREMENTS
    * awk
    * sed

AUTHORS
    Kevin Chu
"
}

# parse_yaml()
#
# Parse YAML file to a string that can be evaluated to define shell variables.
#
# Typical usage: eval $(parse_yaml FILE PREFIX)
#
# Parameters
# ----------
# file: YAML file to parse
#
# prefix (OPTIONAL): prefix for keys parsed from YAML file
#
# Notes
# -----
# * Acknowledgments: parse_yaml() function is based on a solutions
#   provided by Stefan Farestam and Martin Hecht on StackOverflow.

function parse_yaml {
    local file=$1
    local prefix=$2
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')

    sed -ne "s|,$s\]$s\$|]|" \
        -e ":1;s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1  - \4|;t1" \
        -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1  - \3|;p" $file | \
    sed -ne "s|,$s}$s\$|}|" \
        -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1  \3: \4|;t1" \
        -e    "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1  \2|;p" | \
    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p" \
        -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|p" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" | \
    awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
        if(length($2)== 0){  vname[indent]= ++idx[indent] };
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) { vn=(vn)(vname[i])("_")}
            printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, vname[indent], $3);
        }
    }'
}

# run_cmd()
#
# Run command and log output to file.
#
# Parameters
# ----------
# log_file: file to log output to
#
# cmd: command to execute
#
# Return value
# ------------
# cmd_status: exit status of command

function run_cmd
{
    local log_file=$1
    local cmd=${@:2}

    # Echo command to log file
    echo "" >> $log_file
    echo "$ $cmd" >> $log_file
    echo "" >> $log_file

    # Run command
    eval $cmd >> $log_file 2>&1

    # Return command status
    echo $?
}


#-----------------------------------------------------------------------------
# Constants
#-----------------------------------------------------------------------------

# Status codes
_EXIT_CODE_SUCCESS=0
_EXIT_CODE_CMD_OPT_ERR=-1
_EXIT_CODE_ERR_MISSING_CONFIG_FILE_ARG=-2
_EXIT_CODE_CONFIG_FILE_NOT_FOUND=-3
_EXIT_CODE_CONFIG_FILE_ERR_NO_REPOSITORY_NAME=-10
_EXIT_CODE_CONFIG_FILE_ERR_NO_STORAGE_PROVIDER=-20
_EXIT_CODE_CONFIG_FILE_ERR_INVALID_STORAGE_PROVIDER=-21
_EXIT_CODE_CONFIG_FILE_ERR_NO_STORAGE_NAME=-22
_EXIT_CODE_CONFIG_FILE_ERR_NO_LOCAL_STORAGE_DIR=-30
_EXIT_CODE_CONFIG_FILE_ERR_LOCAL_STORAGE_DIR_DOES_NOT_EXIST=-31
_EXIT_CODE_CONFIG_FILE_ERR_NO_AWS_S3_BUCKET=-40
_EXIT_CODE_CONFIG_FILE_ERR_INSTALL_DVC_FAILED=-50
_EXIT_CODE_CONFIG_FILE_ERR_INITIALIZE_DVC_FAILED=-51
_EXIT_CODE_CONFIG_FILE_ERR_ADD_REMOTE_STORAGE_FAILED=-52

# Configuration validation
_VALID_STORAGE_PROVIDERS="local aws"

# Data directory
_DATA_DIR="data"

# Error file
_SCRIPT_NAME=`basename $0`
_ERR_FILE="${_SCRIPT_NAME%.sh}.err"

#-----------------------------------------------------------------------------
# Process command-line
#-----------------------------------------------------------------------------

# Default options
quiet=false

# Process options
options=":qh"
optind=1
while getopts "$options" opt; do
    case $opt in
        q)
            quiet=true
            ;;
        h)
            usage
            exit $_EXIT_CODE_SUCCESS
            ;;
        \?)
            usage
            exit $_EXIT_CODE_CMD_OPT_ERR
            ;;
        \:)
            echo "Option -$optarg requires an argument." >&2
            usage
            exit $_EXIT_CODE_CMD_OPT_ERR
            ;;
    esac
done

# Process arguments
shift $((optind-1))
if [ $# -lt 1 ]; then
    echo "ERROR: CONFIG_FILE argument missing." >&2
    usage
    exit $_EXIT_CODE_ERR_MISSING_CONFIG_FILE_ARG
fi
if [ $# -gt 1 ]; then
    echo "WARNING: more than arguments found.  Ignoring all but first one."
fi
config_file=$1

# Check command-line arguments
if [ ! -z "$config_file" ]; then
    if [ ! -f "$config_file" ]; then
        echo "ERROR: CONFIG_FILE '$config_file' not found." >&2
        exit $_EXIT_CODE_CONFIG_FILE_NOT_FOUND
    fi
fi

#-----------------------------------------------------------------------------
# Read configuration file
#-----------------------------------------------------------------------------

# --- Load parameter values from configuration file

if [ ! -z "$config_file" ]; then
    eval $(parse_yaml $config_file "CONF__")
fi

# --- DVC repository parameters

# repository_name
if [ ! -z "$CONF__repository_name" ]; then
    repository_name=$CONF__repository_name
else
    echo "ERROR: 'repository_name' not set in config file '$config_file'." >&2
    exit $_EXIT_CODE_CONFIG_FILE_ERR_NO_REPOSITORY_NAME
fi

# --- Storage parameters

# storage_provider
if [ ! -z "$CONF__storage_provider" ]; then
    storage_provider=$CONF__storage_provider
else
    echo "ERROR: 'storage_provider' not set in config file '$config_file'." >&2
    exit $_EXIT_CODE_CONFIG_FILE_ERR_NO_STORAGE_PROVIDER
fi

# Check that storage_provider is valid
if ! [[ " $_VALID_STORAGE_PROVIDERS " =~ " $storage_provider " ]]; then
    valid_values=`echo $_VALID_STORAGE_PROVIDERS | sed 's/[[:space:]]\{1,\}/, /g'`
    echo "ERROR: invalid storage provider '$storage_provider'" >&2
    echo "Valid values: $valid_values" >&2
    exit $_EXIT_CODE_CONFIG_FILE_ERR_INVALID_STORAGE_PROVIDER
fi

# storage_name
if [ ! -z "$CONF__storage_name" ]; then
    storage_name=$CONF__storage_name
else
    echo "ERROR: 'storage_name' not set in config file '$config_file'." >&2
    exit $_EXIT_CODE_CONFIG_FILE_ERR_NO_STORAGE_NAME
fi

# ------ "local" storage parameters

if [ "$storage_provider" = "local" ]; then
    if [ ! -z "$CONF__local_storage_dir" ]; then
        local_storage_dir="${CONF__local_storage_dir/#\~/$HOME}"
    else
        echo "ERROR: 'local_storage_dir' not set in config file '$config_file'." >&2
        exit $_EXIT_CODE_CONFIG_FILE_ERR_NO_LOCAL_STORAGE_DIR
    fi

    if [ ! -d "$local_storage_dir" ]; then
        echo "ERROR: local storage directory '$local_storage_dir' does not exist" >&2
        exit $_EXIT_CODE_CONFIG_FILE_ERR_LOCAL_STORAGE_DIR_DOES_NOT_EXIST
    fi
fi

# ------ "aws" storage parameters

if [ "$storage_provider" = "aws" ]; then

    # aws_profile
    if [ ! -z "$CONF__aws_profile" ]; then
        aws_profile=$CONF__aws_profile
    else
        aws_profile="default"
    fi

    # aws_s3_bucket
    if [ ! -z "$CONF__aws_s3_bucket" ]; then
        aws_s3_bucket=$CONF__aws_s3_bucket
    else
        echo "ERROR: 'aws_s3_bucket' not set in config file '$config_file'." >&2
        exit $_EXIT_CODE_CONFIG_FILE_ERR_NO_AWS_S3_BUCKET
    fi
fi

#-----------------------------------------------------------------------------
# Preparations
#-----------------------------------------------------------------------------

# Find top-level dev-ops directory
top_dir=$(cd $(dirname $(dirname ${BASH_SOURCE[0]})); pwd)

# Change to the top directory
cd $top_dir

# --- Install DVC

status_message="Installing DVC..."
echo $status_message >> $_ERR_FILE
if ! $quiet; then
    echo -n $status_message
fi

# Determine optional dependencies for DVC package
if [ "$storage_provider" = "local" ]; then
    dvc_pkg=dvc
elif [ "$storage_provider" = "aws" ]; then
    dvc_pkg=dvc[s3]
fi

# Generate requirements.txt file
cmd="echo '# DVC' > requirements.txt; echo $dvc_pkg >> requirements.txt"
cat_requirements_status=$(run_cmd $_ERR_FILE $cmd)

# Install DVC
cmd="pip install -r requirements.txt"
pip_install_status=$(run_cmd $_ERR_FILE $cmd)

if [ $cat_requirements_status -ne 0 -o $pip_install_status -ne 0 ]; then
    echo "ERROR: Failed to install DVC. For details, see '$_ERR_FILE'" >&2
    exit $_EXIT_CODE_CONFIG_FILE_ERR_INSTALL_DVC_FAILED
else
    rm -f $_ERR_FILE

    if ! $quiet; then
        echo "done"
    fi
fi

#-----------------------------------------------------------------------------
# Initialize DVC
#-----------------------------------------------------------------------------

# --- Initialize DVC

status_message="Initializing DVC..."
echo $status_message >> $_ERR_FILE
if ! $quiet; then
    echo -n $status_message
fi

# Initialize DVC
cmd="dvc init"
dvc_init_status=$(run_cmd $_ERR_FILE $cmd)

# Commit DVC files to git repository
cmd="git commit -m \"Initialize DVC\""
git_commit_status=$(run_cmd $_ERR_FILE $cmd)

if [ $dvc_init_status -ne 0 -o $git_commit_status -ne 0 ]; then
    echo "ERROR: Failed to initialize DVC. For details, see '$_ERR_FILE'" >&2
    exit $_EXIT_CODE_CONFIG_FILE_ERR_INITIALIZE_DVC_FAILED
else
    rm -f $_ERR_FILE

    if ! $quiet; then
        echo "done"
    fi
fi

# --- Add remote storage

if ! $quiet; then
    echo -n "Adding remote storage for DVC..."
fi

# Set remote storage URL
if [ "$storage_provider" = "local" ]; then
    remote_storage_url=$local_storage_dir
elif [ "$storage_provider" = "aws" ]; then
    remote_storage_url="s3://$aws_s3_bucket"
fi

# Add DVC remote storage
cmd="dvc remote add -d $storage_name $remote_storage_url"
dvc_remote_add_status=$(run_cmd $_ERR_FILE $cmd)

# Add DVC files to git repository
cmd="git add .dvc/config"
git_add_status=$(run_cmd $_ERR_FILE $cmd)

# Commit DVC files to git repository
cmd="git commit -m \"Add remote storage\""
git_commit_status=$(run_cmd $_ERR_FILE $cmd)

if [ $dvc_remote_add_status -ne 0 -o $git_add_status -ne 0 -o $git_commit_status -ne 0 ]; then
    echo "ERROR: Failed to add remote storage. For details, see '$_ERR_FILE'" >&2
    exit $_EXIT_CODE_CONFIG_FILE_ERR_ADD_REMOTE_STORAGE_FAILED
else
    rm -f $_ERR_FILE

    if ! $quiet; then
        echo "done"
    fi
fi

# --- Transfer tracking of data directory from Git to DVC

status_message="Transferring tracking of '$_DATA_DIR' directory from Git to DVC..."
echo $status_message >> $_ERR_FILE
if ! $quiet; then
    echo -n $status_message
fi

# Remove $_DATA_DIR from git management
cmd="git rm -r --cached $_DATA_DIR"
git_rm_status=$(run_cmd $_ERR_FILE $cmd)

# Remove .git-keep-dir
cmd="rm -f $_DATA_DIR/.git-keep-dir"
rm_git_keep_dir_status=$(run_cmd $_ERR_FILE $cmd)

# Add $_DATA_DIR to DVC management
cmd="dvc add $_DATA_DIR"
dvc_add_status=$(run_cmd $_ERR_FILE $cmd)

# Add DVC files to git repository
cmd="git add $_DATA_DIR.dvc"
git_add_status=$(run_cmd $_ERR_FILE $cmd)

# Commit DVC files to git repository
cmd="git commit -m \"Transfer tracking of '$_DATA_DIR' directory from Git to DVC\""
git_commit_status=$(run_cmd $_ERR_FILE $cmd)

if [ $git_rm_status -ne 0 -o $rm_git_keep_dir_status -ne 0 -o $dvc_add_status -ne 0 -o $git_add_status -ne 0 -o $git_commit_status -ne 0 ]; then
    echo "ERROR: Failed to transfer tracking of '$_DATA_DIR' directory to DVC." >&2
    echo "For details, see '$_ERR_FILE'" >&2
    exit $_EXIT_CODE_CONFIG_FILE_ERR_ADD_REMOTE_STORAGE_FAILED
else
    rm -f $_ERR_FILE

    if ! $quiet; then
        echo "done"
    fi
fi
