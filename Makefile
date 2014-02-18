# Add it here or on cmdline
INSTANCE_NAME=ckan-test
IMGS=$(INSTANCE_NAME).iso

PAYLOAD=$(shell find payload -maxdepth 1 -type f -not -name .\*)
CLOUD_CONFIG=$(shell find payload -maxdepth 1 -name \*cloud-config -type f -not -name .\*)
GEN=.validate_cloud_config .validate_shell

combined-userdata.gz: $(GEN) $(PAYLOAD)
	write-mime-multipart --gzip --output=$@ $(PAYLOAD)
	@if [ $$(perl -e '@x=stat(shift);print $$x[7]' $@) -gt 16384 ] ; then \
		echo "Huston, we got a size problem" ; \
		exit 1 ; \
	fi

clean:
	rm -f combined-userdata.gz user-data meta-data *.iso $(GEN)

#XXX: validate shellscripts?
.validate_shell: $(PAYLOAD)
	bash -n $?
	touch $@

.validate_cloud_config: $(CLOUD_CONFIG)
	bin/val.py $?
	@touch $@

meta-data:
	@if [ "$(INSTANCE_NAME)" = "" ] ; then\
		echo "DEFINE INSTANCE_NAME!";\
		exit 1;\
	fi
	echo "local-hostname: $(INSTANCE_NAME)" > $@

user-data: combined-userdata.gz
	cp $^ $@

%.iso: meta-data user-data
	@if [ ! "$(shell which genisoimage)" = "" ] ; then \
		genisoimage -output $@ -volid cidata -joliet -rock $^ ; \
	elif [ ! "$(shell which hdiutil)" = "" ] ; then \
		mkdir tmpdir ; \
		cp $^ tmpdir ; \
		hdiutil makehybrid -iso -joliet -o $@ -default-volume-name cidata tmpdir ; \
		rm -rf tmpdir ; \
		perl -pi -e 's/CIDATA/cidata/' $@ ; \
	else \
		echo "I don't know any way to make a iso on this system" ; \
	fi
