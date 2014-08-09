BUCKET = knut-ahlers.de
EXPIRY_DAYS = 8

TEMPLATES = $(wildcard templates/tpl_*)
EXPIRY = $(shell python -c "print $(EXPIRY_DAYS) * 86400")
SCSS_FILES = $(wildcard ./scss/*)

define gen_template
		./scripts/jinja.py $1 > rendered/tmp_$(subst tpl_,,$(notdir $1));
		htmlmin rendered/tmp_$(subst tpl_,,$(notdir $1)) rendered/$(subst tpl_,,$(notdir $1));
		rm rendered/tmp_$(subst tpl_,,$(notdir $1));
endef

default: test

clean_%:
		rm -rf ./$*/

clean_prerun:
		find . -name '.DS_Store' -delete

clean: clean_node_modules clean_prerun clean_testing clean_publish clean_rendered

build_style: $(SCSS_FILES)
		mkdir -p ./rendered/
		./scripts/sass_gen.py $(SCSS_FILES) > ./rendered/style.min.css

render: $(TEMPLATES)
		mkdir -p ./rendered/
		$(foreach tplname,$(TEMPLATES),$(call gen_template,$(tplname)))

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
