# twitter-to-mastodon
A crude bash script that mirrors an unlimited number of Twitter accounts and post them to Mastodon. It uses [Nitter](https://github.com/zedeus/nitter) RSS streams as source—Twitter's API is not involved. _Text only_, images are not re-posted (but a link to the original Nitter post is included in the post). The visibility of posts is set to 'Followers only'—the posts/account(s) are not meant to be reblogged/boosted. The script can either post all feeds to one single Mastodon account, or one separate account per feed (default). Run the script with `cron` for automated posting.

Tested on a Raspberry Pi/Debian only.

## Requires
* jq
* xq
* [toot](https://github.com/ihabunek/toot)

## Setup
- rename **feeds_example.json** to **feeds.json** and add the Twitter accounts (Nitter RSS feeds) (also change the preferred [Nitter instance](https://github.com/xnaas/nitter-instances))
- if posting with _multiple_ Mastodon accounts (default):
  - register and setup new Mastodon accounts, one per Twitter account you wish to mirror
  - the Mastodon **account name** and `feed_name` in **feeds.json** _must be the same_
- if posting all feeds with _one single_ Mastodon account:
  - register and setup a new Mastodon account
  - set `use_combined_account` in **post.sh** to `true` and change `combined_account_name` to the Mastodon account you want to use
 - change `mastodon_instance` in **post.sh** to the instance where you have your Mastodon account(s)
 - authenticate your Mastodon account(s) with `toot`
