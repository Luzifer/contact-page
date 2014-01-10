BUCKET = 'knut-ahlers.de'
TEMPLATES = $(wildcard templates/tpl_*)
EXPIRY = $(shell python -c "from datetime import *; print (datetime.utcnow() + timedelta(days=8)).strftime('%a, %d %b %Y %H:%M:%S GMT')")

define swig_template
		./node_modules/.bin/swig render $1 > rendered/$(subst tpl_,,$(notdir $1));
endef

install_npm:
		npm install swig minify

clean_npm:
		rm -rf ./node_modules/

clean_prerun:
		find . -name '.DS_Store' -delete

build_style: install_npm
		./node_modules/.bin/minify style.css rendered/style.min.css

render: $(TEMPLATES) install_npm
		mkdir -p rendered
		$(foreach tplname,$(TEMPLATES),$(call swig_template,$(tplname)))

publish: render build_style
		s3cmd sync -P ./rendered/ s3://$(BUCKET)/
		s3cmd sync -P ./files/ s3://$(BUCKET)/files/
		s3cmd sync -P --add-header="Expires:$(EXPIRY)" --delete-removed ./lib/ s3://$(BUCKET)/lib/
		s3cmd sync -P --add-header="Expires:$(EXPIRY)" --delete-removed ./images/ s3://$(BUCKET)/images/

clean: clean_npm clean_prerun
		rm -rf ./rendered/

