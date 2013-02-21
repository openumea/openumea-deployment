# Add it here or on cmdline
INSTANCE_NAME=ckan-test
IMGS=$(INSTANCE_NAME).iso
ROOT_SIZE=20G
SERVER=vmserver1.lan
IMG_DIR=/var/lib/libvirt/images/
KVM_VG=KVM
INSTANCE_DISK=/dev/$(KVM_VG)/$(INSTANCE_NAME)
OS_IMAGE=precise-server-cloudimg-amd64-disk1.img

PAYLOAD=$(shell find payload -maxdepth 1 -type f -not -name .\*)
CLOUD_CONFIG=$(shell find payload -maxdepth 1 -name \*cloud-config -type f -not -name .\*)
GEN=.validate_cloud_config .validate_shell

combined-userdata.gz: $(GEN) $(PAYLOAD)
	write-mime-multipart --gzip --output=$@ $(PAYLOAD)
	@if [ $$(du -k $@ | cut -f 1) -gt 16 ] ; then \
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
	genisoimage -output $@ -volid cidata -joliet -rock $^

push_data: $(IMGS)
	rsync -v $^ $(SERVER):$(IMG_DIR)

$(INSTANCE_NAME).xml: BASE.xml
	cp $^ $(INSTANCE_NAME).tmp
	perl -pi -e 's,INSTANCE_NAME,$(INSTANCE_NAME), ; s,INSTANCE_DISK,$(INSTANCE_DISK),' $(INSTANCE_NAME).tmp
	mv $(INSTANCE_NAME).tmp $(INSTANCE_NAME).xml

vm_create: push_data $(INSTANCE_NAME).xml
	echo "NOT AVAILABLE"
	exit -1
	ssh $(SERVER) lvcreate -L $(ROOT_SIZE) -n $(INSTANCE_NAME) $(KVM_VG)
	cat $(INSTANCE_NAME).xml | ssh $(SERVER) virsh define /dev/stdin
	rm $(INSTANCE_NAME).xml
	make vm_recreate

vm_terminate:
	ssh $(SERVER) virsh destroy $(INSTANCE_NAME)
	ssh $(SERVER) virsh undefine $(INSTANCE_NAME)
	ssh $(SERVER) lvremove -ff $(INSTANCE_DISK)

vm_recreate: push_data
	ssh $(SERVER) virsh destroy $(INSTANCE_NAME)
	ssh $(SERVER) qemu-img convert -O host_device $(IMG_DIR)/$(OS_IMAGE) $(INSTANCE_DISK)
	ssh $(SERVER) virsh start $(INSTANCE_NAME)
