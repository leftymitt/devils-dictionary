#! /bin/bash

FILE="bierce-devils-286.txt"

BLOCK=""
NBLOCK=""

LETTER=""
TERM=""
TYPE=""
DEF=""
POEM=""
AUTHOR=""

MODE="NEW"

function PRINT_WORD() {
	echo "    - word: ${TERM}"
	if ! [ -z "${TYPE}" ]; then
		echo "      type: ${TYPE}"
	fi
	if ! [ -z "${DEF}" ]; then
		echo "      def:  ${DEF}"
	fi
	if ! [ -z "${POEM}" ]; then
		echo "      poem: |+ "
		echo "${POEM}"
		echo "      author: ${AUTHOR}"
	fi
	echo ""
}


echo "dictionary:"

while IFS= read -r CMD; do
	NEWLETTER=$(echo "${CMD}" | sed -e 's/\ //g' | tr -d "\n")
	if [[ "${NEWLETTER}" =~ ^(A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z)$ ]]; then
		if ! [ -z "${TERM}" ]; then
			PRINT_WORD
		fi

		LETTER=${NEWLETTER}
		echo " - letter: ${LETTER}"
		echo "   terms:"

		BLOCK=""
		NBLOCK=""

		TERM=""
		TYPE=""
		DEF=""
		POEM=""
		AUTHOR=""

		MODE="NEW"
		continue
	fi

	if [ "${MODE}" == "NEW" ]; then
		BLOCK=${BLOCK}${CMD}
	elif [ "${MODE}" == "WAIT" ]; then
		NBLOCK=${NBLOCK}$(echo "${CMD}" | sed -e 's/^[ \t]*//g' | sed -e 's/^/         /g')$'\n'
	fi


#	NEWTERM=$(echo "${CMD}" | sed -n "s/\(^[A-Z][A-Z|'|-]*[A-Z]\),.*/\1/p")
	NEWTERM=$(echo "${CMD}" | sed -n "s/\(^[A-Z][A-Z|(|)|-| |o|r]*[A-Z]\)[,|.].*/\1/p")

	if ! [ -z "${NEWTERM}" ]; then 
		if ! [ -z "${TERM}" ]; then 
			MODE="NEW"
			PRINT_WORD

			BLOCK="${CMD}"
			NBLOCK=""

			TERM=""
			TYPE=""
			DEF=""
			POEM=""
			AUTHOR=""
		fi
	fi

	if [ "${CMD}" == '' ]; then
		if [ "${MODE}" == "NEW" ]; then
#			TERM=$(echo "${BLOCK}" | perl -pe "s|(^[A-Z]+[A-Z'()or -]*[A-Z])[,\.].*|\1|" | tail -1)
#			TYPE=$(echo "${BLOCK}" | sed -n "s/\(^[A-Z].*[A-Z]\)[,\.]\ \(.*\.\).*/\2/p" | cut -d" " -f1)
#			DEF=$(echo "${BLOCK}" | perl -pe "s|^[A-Z]+[A-Z'()or -]*[A-Z\|'\|-]*[A-Z],\ .*?\.\ \ (.*)|\1|")
			TERM=$(echo "${BLOCK}" | perl -pe "s/(^[A-Z][A-Z| ()or']*[A-Z])[.|,] ?(.*?\.)? *(.*\.)?/\1/p")
			TYPE=$(echo "${BLOCK}" | perl -pe "s/(^[A-Z][A-Z| ()or']*[A-Z])[.|,] ?(.*?\.)? *(.*\.)?/\2/p")
			DEF=$(echo "${BLOCK}" | perl -pe "s/(^[A-Z][A-Z| ()or']*[A-Z])[.|,] ?(.*?\.)? *(.*\.)?/\3/p")
#			if ! [ -z "${TERM}" ] && [ "${TERM}" != "\n" ]; then
			if ! [ -z "${TERM}" ]; then
				MODE="WAIT"
			fi
		elif [ "${MODE}" == "WAIT" ]; then
			POEM=$(echo "${NBLOCK}" | sed -e '$ d' | sed -e '$ d' | sed -e '$ d')
			AUTHOR=$(echo "${NBLOCK}" | sed -e '$ d' | sed -e '$ d' | sed -n 's/\ *\([^\s\\]\)/\1/p' | tail -1)
		fi
	fi

done < "$FILE"
