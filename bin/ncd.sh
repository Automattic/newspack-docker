ncd() {

	if [ -z "$1" ]
	then
		echo "You need to inform the name of the directory you want to cd into"

	fi

	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

	# The complete name of a repo:
	if [[ -d "$SCRIPT_DIR/../repos/$1" ]]; then
		cd "$SCRIPT_DIR/../repos/$1"
		return
	fi

	# The name of a repo without the newspack- prefix:
	if [[ -d "$SCRIPT_DIR/../repos/newspack-$1" ]]; then
		cd "$SCRIPT_DIR/../repos/newspack-$1"
		return
	fi

	# An additional site:
	if [[ -d "$SCRIPT_DIR/../additional-sites-html/$1" ]]; then
		cd "$SCRIPT_DIR/../additional-sites-html/$1"
		return
	fi

	# A plugin in the main site:
	if [[ -d "$SCRIPT_DIR/../html/wp-content/plugins/$1" ]]; then
		cd "$SCRIPT_DIR/../html/wp-content/plugins/$1"
		return
	fi

	echo "No matches found for $1"

}
