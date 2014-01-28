BUCKET = knut-ahlers.de
EXPIRY_DAYS = 8

TEMPLATES = $(wildcard templates/tpl_*)
EXPIRY = $(shell python -c "print $(EXPIRY_DAYS) * 86400")

define swig_template
		./node_modules/.bin/swig render $1 > rendered/tmp_$(subst tpl_,,$(notdir $1));
		./node_modules/.bin/minify rendered/tmp_$(subst tpl_,,$(notdir $1)) rendered/$(subst tpl_,,$(notdir $1));
		rm rendered/tmp_$(subst tpl_,,$(notdir $1));
endef

default: test

install_npm_%:
		npm install $*

clean_%:
		rm -rf ./$*/

clean_prerun:
		find . -name '.DS_Store' -delete

clean: clean_node_modules clean_prerun clean_testing clean_publish clean_rendered

build_style: install_npm_node-sass
		mkdir -p ./rendered/
		./node_modules/.bin/node-sass --output-style compressed --include-path scss ./scss/style.scss ./rendered/style.min.css

render: $(TEMPLATES) install_npm_swig install_npm_minify
		mkdir -p ./rendered/
		$(foreach tplname,$(TEMPLATES),$(call swig_template,$(tplname)))

collect: render build_style
		mkdir -p ./rendered/
		rsync -ar ./files/ ./rendered/
		rsync -ar ./lib/ ./rendered/
		rsync -ar ./images/ ./rendered/

compress: collect
		mkdir -p ./publish/
		python scripts/aws-s3-gzip-compression.py ./rendered/ ./publish/

publish: clean compress
		s3cmd sync ./publish/ s3://$(BUCKET)/ \
				-P --exclude '*' --include '*.js' \
				--add-header 'Content-Encoding:gzip' \
				--mime-type="application/javascript; charset=utf-8" \
				--add-header "Cache-Control: max-age=$(EXPIRY)" && \
		s3cmd sync ./publish/ s3://$(BUCKET)/ \
				-P --exclude '*' --include '*.css' \
				--add-header 'Content-Encoding:gzip' \
				--mime-type="text/css; charset=utf-8" \
				--add-header "Cache-Control: max-age=$(EXPIRY)" && \
		s3cmd sync ./publish/ s3://$(BUCKET)/ \
				-P --exclude '*' --include '*.html' \
				--add-header 'Content-Encoding:gzip' \
				--mime-type="text/html; charset=utf-8" && \
		s3cmd sync ./publish/ s3://$(BUCKET)/ \
				-P --exclude '*' --include '*.png' --include '*.jpg' --include '*.gif' \
				--add-header "Cache-Control: max-age=$(EXPIRY)" && \
		s3cmd sync ./publish/ s3://$(BUCKET)/ \
				-P --delete-removed

test: clean collect
		mkdir -p ./testing/
		rsync -ar ./rendered/ ./testing/

serve: test
		cd ./testing/ && python -m SimpleHTTPServer 8000
