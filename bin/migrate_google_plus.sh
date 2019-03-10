#!/bin/sh

set -eu

workDir="Posts"

parse_value() {
	echo "$1" | grep -Eo ': ".+".?$' | cut -c '4-' | grep -Eo '^[^"]+'
}

de_entity() {
    echo "$1" | sed 's/&amp;/\&/g; s/&lt;/\</g; s/&gt;/\>/g; s/&quot;/\"/g; s/&#39;/\'"'"'/g; s/&ldquo;/\"/g; s/&rdquo;/\"/g;'
}

filesystem_safe() {
	echo "$1" | sed -E 's/!//g; s/\|//g; s/\//-/g; s/<.*$//g; s/\(//g; s/\)//g; s/"//g; s/://g; s/\..*$//;'
}

generate_output_name() {
	creationTime="$1"
	localFilePath="$2"
	content="$3"

	baseName=`basename "$localFilePath"`
	if [ -n "$content" ]; then
		fileName="$creationTime - $content.${baseName##*.}"
	else
		fileName="$creationTime - $baseName"
	fi

	echo "$fileName"
}


mkdir -p output

find "$workDir" -name "*.json" | while read file; do

	fileCount=`cat "$file" | grep -c '"localFilePath":'` || true
	if [ "$fileCount" -gt 0 ]; then

		creationTime=`cat "$file" | grep '"creationTime":' | head -n 1`
		creationTime=`parse_value "$creationTime" | cut -b '1-10'`

		content=`cat "$file" | grep '"content":' | head -n 1` || true
		if [ -n "$content" ]; then
			content=`parse_value "$content"`
			content=`echo "$content" | ./unescape_unicode.pl`
			content=`de_entity "$content"`
			content=`filesystem_safe "$content"`
		fi

		if [ "$fileCount" -eq 1 ]; then
			localFilePath=`cat "$file" | grep '"localFilePath":'`
			localFilePath=`parse_value "$localFilePath"`

			fileName="`generate_output_name "$creationTime" "$localFilePath" "$content"`"

			cp -v "./$workDir/$localFilePath" "output/$fileName"
		else
			if [ -z "$content" ]; then
				content="unnamed album"
			fi
			dirName="$creationTime - $content"

			mkdir -pv "output/$dirName"

			cat "$file" | grep '"localFilePath":' | while read localFilePath; do
				localFilePath=`parse_value "$localFilePath"`

				fileName="`basename "$localFilePath"`"

				cp -v "./$workDir/$localFilePath" "output/$dirName/$fileName"
			done
		fi
	fi
done

echo "Done!"

