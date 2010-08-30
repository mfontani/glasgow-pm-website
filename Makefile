all: prereqs xslate scp push

xslate:
	xslate templates/ -o htdocs/ -x tx=html -i 'page.tx|.swp'

prereqs:
	perl prereqs.pl

scp:
	scp -r htdocs/* darkpan:/var/www/glasgow/

push:
	git push origin master

edit:
	vim -p templates/* htdocs/glasgow-site.css
