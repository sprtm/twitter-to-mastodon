#!/bin/bash


## properties
work_dir="$(dirname -- "${BASH_SOURCE[0]}")"
feed_cache_dir="${work_dir}/feed_cache"
feed_items_dir="${work_dir}/feed_items"
mastodon_instance="@example.domain" # i.e. '@mastodon.social'
use_combined_account=false
combined_account_name="placeholder"
feed_list="${work_dir}/feeds.json"


function check_directories {
	if [[ ! -d "${feed_cache_dir}" ]]; then
		mkdir "${feed_cache_dir}"
	fi

	if [[ ! -d "${feed_items_dir}" ]]; then
		mkdir "${feed_items_dir}"
	fi
}

function scan_feeds {
	< "${feed_list}" jq -r '.[] | [.feed_id, .feed_name, .feed_url] | @tsv' |
	while IFS=$'\t' read -r feed_id feed_name feed_url; do
		if [[ ! -d "${feed_items_dir}/${feed_id}-${feed_name}" ]]; then
			mkdir "${feed_items_dir}/${feed_id}-${feed_name}"
		fi
		if [[ ! -d "${feed_cache_dir}/${feed_id}-${feed_name}" ]]; then
			mkdir "${feed_cache_dir}/${feed_id}-${feed_name}"
		fi
		curl -s "${feed_url}" | xq . | jq -r '.rss.channel.item[] | .title |=@base64 | .link |=@base64 | .title + ";;" + .link' > "${feed_items_dir}/${feed_id}-${feed_name}/items"
		if [[ "${use_combined_account}" = true ]]; then
			mastodon_user="${combined_account_name}"
		else
			mastodon_user="${feed_name}"
		fi
		post_status
	done
}

function post_status {
	arr=()
	while IFS= read -r line; do
		arr+=("${line}")
		url=$(echo "${line}" | sed -n 's/^.*;;//p' | base64 -d)
		url_hash=$(echo -e "${url}" | sha256sum | head -c 64)
		title=$(echo "${line}" | sed -n 's/;;.*//p' | base64 -d)
		if [[ ! -f  "${feed_cache_dir}/${feed_id}-${feed_name}/${url_hash}" ]]; then
			echo "${title}" > "${feed_cache_dir}/${feed_id}-${feed_name}/${url_hash}"
			if [[ "${use_combined_account}" = true ]]; then
				statusToPost=$(echo -e "${feed_name}:\n${title}\n\n${url}")
			else
				statusToPost=$(echo -e "${title}\n\n${url}")
			fi
			echo "Toot: ${statusToPost}"
			
			toot post -u "${mastodon_user}${mastodon_instance}" "${statusToPost}" -v private
		fi
	done < "${feed_items_dir}/${feed_id}-${feed_name}/items"
}


## main
check_directories
scan_feeds