ncd() {

	if [ -z "$1" ]
	then
		echo "You need to inform the name of the directory you want to cd into"

	fi

	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	[[ "${SCRIPT_DIR}" == */ ]] && SCRIPT_DIR="${SCRIPT_DIR: : -1}"
	TRIES=10

	while [ $TRIES -gt 0 ]; do
		TRIES=$((TRIES-1))
		if [[ -d "$SCRIPT_DIR/repos" ]]; then
			break
		fi
		SCRIPT_DIR="$SCRIPT_DIR/.."
	done;

	DESTINATION=null

	# The complete name of a repo:
	if [[ -d "$SCRIPT_DIR/repos/$1" ]]; then
		DESTINATION="$SCRIPT_DIR/repos/$1"
	fi

	# The name of a repo without the newspack- prefix:
	if [[ -d "$SCRIPT_DIR/repos/newspack-$1" ]]; then
		DESTINATION="$SCRIPT_DIR/repos/newspack-$1"
	fi

	# An additional site:
	if [[ -d "$SCRIPT_DIR/../additional-sites-html/$1" ]]; then
		DESTINATION="$SCRIPT_DIR/additional-sites-html/$1"
	fi

	# A plugin in the main site:
	if [[ -d "$SCRIPT_DIR/html/wp-content/plugins/$1" ]]; then
		DESTINATION="$SCRIPT_DIR/html/wp-content/plugins/$1"
	fi

	echo "DESTINATION: $DESTINATION"

	if [[ "$DESTINATION" != null ]]; then
		cd "$DESTINATION"
		echo "Navigated to $DESTINATION!"
		return
	fi

	echo "No directory found for $1"

}
