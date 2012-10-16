PAYLOAD=$(shell find payload -maxdepth 1 -type f -not -name .\*)
CLOUD_CONFIG=$(shell find payload -maxdepth 1 -name \*cloud-config -type f -not -name .\*)
GEN=.validate_cloud_config .validate_shell
# test data
IMGS=nocloud.iso
SERVER=vmserver1.lan
IMG_DIR=/var/lib/libvirt/images/
KVM_VG=KVM
INSTANCE_NAME=ckan-test
OS_IMAGE=precise-server-cloudimg-amd64-disk1.img

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

push_data: $(IMGS)
	rsync -v $^ $(SERVER):$(IMG_DIR)

vm_create: push_data
	#ssh $(SERVER) lvcreate -L 2G -n $(INSTANCE_NAME) $(KVM_VG)
	#ssh $(SERVER) virsh define ...

vm_recreate: push_data
	ssh $(SERVER) virsh destroy $(INSTANCE_NAME)
	ssh $(SERVER) qemu-img convert -O host_device $(IMG_DIR)/$(OS_IMAGE) /dev/$(KVM_VG)/$(INSTANCE_NAME)
	ssh $(SERVER) virsh start $(INSTANCE_NAME)
