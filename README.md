bup - Backup utility that creates gzipped tarballs of directories

USAGE:
    /usr/local/bin/bup <directory> [OPTIONS]

ARGUMENTS:
    directory           Directory to backup

OPTIONS:
    -o output_directory Specify alternative directory to store the tarball
                       (default: current directory)
    -v, --verbose      Enable verbose output and set BUP_VERBOSE environment
                       variable for pre/post scripts
    -h, --help         Show this help message

DESCRIPTION:
    Creates a gzipped tarball of the specified directory with automatic naming:
    bak.[directory_name].[YYYY-mm-dd].tgz
    
    If a file with the same name exists, a numeric suffix is added:
    bak.[directory_name].[YYYY-mm-dd].1.tgz

AUTOMATIC SCRIPT EXECUTION:
    If present, the following scripts are automatically executed:
    
    .bup-pre.sh        Executed before creating the backup tarball
                       - Script runs in the target directory
                       - If script fails, backup is aborted
                       - Receives BUP_VERBOSE=1 environment variable in verbose mode
    
    .bup-post.sh       Executed after creating the backup tarball
                       - Script runs in the target directory
                       - If script fails, backup continues (warning issued)
                       - Receives BUP_VERBOSE=1 environment variable in verbose mode

ENVIRONMENT VARIABLES:
    BUP_VERBOSE        Set to "1" when --verbose flag is used, available to
                       .bup-pre.sh and .bup-post.sh scripts

EXAMPLES:
    /usr/local/bin/bup /home/user/project
    /usr/local/bin/bup /home/user/project -o /backup/location
    /usr/local/bin/bup /home/user/project --verbose
    /usr/local/bin/bup /home/user/project -o /backup -v
