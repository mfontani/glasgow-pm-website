all: prereqs xslate

xslate:
	xslate -d 1 -w 5 templates/ -I templates/meetings/ -o htdocs/ -x tx=html -i 'page.tx|.swp'
	mv htdocs/2010-* htdocs/meetings/
	mv htdocs/meetings.html htdocs/meetings/index.html

prereqs:
	perl prereqs.pl

scp:
	scp -r htdocs/* darkpan:/var/www/glasgow/

push:
	git push origin master

edit:
	vim -p $$(find templates/ -type f -name '*.tx') htdocs/glasgow-site.css

minify:
	~/bin/yuicompressor-2.4.2.jar -o htdocs/glasgow-site-mini.css htdocs/glasgow-site.css
