#!/bin/sh

BASE=$(dirname $0)

for domain in test othertest
do
	msgfmt -o $BASE/locale/de_DE/LC_MESSAGES/$domain.mo $BASE/locale/de_DE/LC_MESSAGES/$domain.po
	echo -n "locale_data['$domain'] = " >$BASE/locale/de_DE/LC_MESSAGES/$domain.json
	$BASE/../../share/js/gettext/po2json $BASE/locale/de_DE/LC_MESSAGES/$domain.po >>$BASE/locale/de_DE/LC_MESSAGES/$domain.json
	echo ";" >>$BASE/locale/de_DE/LC_MESSAGES/$domain.json
done
