PAYLOAD=$(shell find payload -maxdepth 1 -type f -not -name .\*)
CLOUD_CONFIG=$(shell find payload -maxdepth 1 -name \*cloud-config -type f -not -name .\*)
GEN=.validate_cloud_config .validate_shell

combined-userdata.gz: $(GEN) $(PAYLOAD)
	write-mime-multipart --gzip --output=$@ $(PAYLOAD)
	@if [ $$(du -b $@ | cut -f 1) -gt 16384 ] ; then \
		echo "Huston, we got a size problem" ; \
		exit 1 ; \
	fi
clean:
	rm -f combined-userdata.gz $(GEN) nocloud.iso

#XXX: validate shellscripts?
.validate_shell: $(PAYLOAD)
	bash -n $?
	touch $@

.validate_cloud_config: $(CLOUD_CONFIG)
	bin/val.py $?
	@touch $@

nocloud.iso: combined-userdata.gz
	mkdir nocloud
	cp $? nocloud/user-data
	echo "local-hostname: ckan-test" > nocloud/meta-data
	(cd nocloud ; genisoimage -output ../$@ -volid cidata -joliet -rock *)
	rm -rf nocloud
	scp nocloud.iso test.dohi.se:/var/lib/libvirt/images/

strunt:
	#$(CLOUD_GEN): $(CLOUD) 
	#foo
	#echo \$\@ = $@
	#echo \$\% = $%
	#echo \$\< = $<
	#echo \$\> = $>
	#echo \$\? = $?
