#!/bin/sh

USAGE="Usage: `basename $0` [-bf] [-d dir] sitename"
DB=false
FOLDER=false
BACKUP_DIR=.

while getopts bfo: OPT; do
    case "$OPT" in
        b)
            DB=true
            ;;
        f)
            FOLDER=true
            ;;
        d)
            BACKUP_DIR=$OPTARG
            ;;
        \?)
            echo $USAGE
            exit 1
            ;;
    esac
done

shift `expr $OPTIND - 1`

if [ $# -eq 0 ]; then
    echo $USAGE
    exit 1
fi

if $FOLDER; then
    tar -zcvf $1-`date +%F--%H-%M`.tar.gz $BACKUP_DIR
fi

if $DB; then
    mysqldump -u root $1 | gzip > `date +$BACKUP_DIR/$1-%F--%H-%M.sql.gz`
fi