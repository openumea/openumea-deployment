PAYLOAD=$(shell find payload -maxdepth 1 -type f -not -name .\*)
CLOUD_CONFIG=$(shell find payload -maxdepth 1 -name \*cloud-config -type f -not -name .\*)
GEN=.validate_cloud_config .validate_shell
# test data
IMGS=nocloud.iso
SERVER=vmserver1.lan
IMG_DIR=/var/lib/libvirt/images/
KVM_VG=KVM
INSTANCE_NAME=ckan-test
INSTANCE_DISK=/dev/$(KVM_VG)/$(INSTANCE_NAME)
OS_IMAGE=precise-server-cloudimg-amd64-disk1.img
ROOT_SIZE=20G

combined-userdata.gz: $(GEN) $(PAYLOAD)
	write-mime-multipart --gzip --output=$@ $(PAYLOAD)
	@if [ $$(du -b $@ | cut -f 1) -gt 16384 ] ; then \
		echo "Huston, we got a size problem" ; \
		exit 1 ; \
	fi

clean:
	rm -f combined-userdata.gz nocloud.iso meta-data user-data $(GEN)

#XXX: validate shellscripts?
.validate_shell: $(PAYLOAD)
	bash -n $?
	touch $@

.validate_cloud_config: $(CLOUD_CONFIG)
	bin/val.py $?
	@touch $@

meta-data:
	echo "local-hostname: ckan-test" > meta-data

user-data: combined-userdata.gz
	cp $^ $@

%.iso: meta-data user-data
	genisoimage -output $@ -volid cidata -joliet -rock $^

push_data: $(IMGS)
	rsync -v $^ $(SERVER):$(IMG_DIR)

vm_create: push_data $(INSTANCE_NAME).xml
	#ssh $(SERVER) lvcreate -L $(ROOT_SIZE) -n $(INSTANCE_NAME) $(KVM_VG)
	#cat $(INSTANCE_NAME).xml | ssh $(SERVER) virsh define /dev/stdin
	#rm $(INSTANCE_NAME).xml
	#make vm_recreate

vm_terminate:
	ssh $(SERVER) virsh destroy $(INSTANCE_NAME)
	ssh $(SERVER) virsh undefine $(INSTANCE_NAME)
	ssh $(SERVER) lvremove -ff $(INSTANCE_DISK)

vm_recreate: push_data
	ssh $(SERVER) virsh destroy $(INSTANCE_NAME)
	ssh $(SERVER) qemu-img convert -O host_device $(IMG_DIR)/$(OS_IMAGE) $(INSTANCE_DISK)
	ssh $(SERVER) virsh start $(INSTANCE_NAME)
