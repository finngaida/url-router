# URL Router
Route URLs to different browsers based on rules

---

## Why?
I found myself in a situation where I use one browser ([Iridium]()) for private use and another ([Chrome]()) for work.		
This poses a problem with opening links in arbitrary applications, since you can only specify one **_Default browser_**.		
Well, no more! URL Router sits in your status bar and routes links to where they should go.

## How?
Either download one of the prebuilt binaries from the [releases section](), or if you don't trust me (you shouldn't), clone the repo and build it yourself with Xcode.	

1. open once and add all the rules you want
	- it's recommendable to add a *"fallback"* rule for all links that don't match a rule: "route links _beginning with_ `http` to *default browser*"
2. Go to system preferences > General and set URL Router as your default browser
