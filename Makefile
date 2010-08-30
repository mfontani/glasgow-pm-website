all: prereqs
	xslate templates/ -o htdocs/ -x tx=html -i 'page.tx|.swp'

prereqs:
	perl prereqs.pl

scp:
	scp -r htdocs/* darkpan:/var/www/glasgow/

edit:
	vim -p templates/* htdocs/glasgow-site.css
