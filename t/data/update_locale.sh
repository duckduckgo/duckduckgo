#!/bin/sh

BASE=$(dirname $0)

msgfmt -o $BASE/locale/de_DE/LC_MESSAGES/test.mo $BASE/locale/de_DE/LC_MESSAGES/test.po
echo -n "locale_data['test'] = " >$BASE/locale/de_DE/LC_MESSAGES/test.json
$BASE/../../share/gettextjs/po2json $BASE/locale/de_DE/LC_MESSAGES/test.po >>$BASE/locale/de_DE/LC_MESSAGES/test.json
echo ";" >>$BASE/locale/de_DE/LC_MESSAGES/test.json

