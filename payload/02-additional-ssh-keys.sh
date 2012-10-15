#!/bin/bash
#
# users to add the key to
USERS="/root /home/ubuntu"

# Add additional ssh keys
KEYS=(
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCFasTXO81OI3AxoHWS9GeThcbQKInvxp3I70QPA8hKtZa6T0Z16Zopx+9Q+c3+tvia+xGf+iT0M8QTisq1Ce1Bst9InOivXUGvsxjDQ5K2z9IPtwTFNvajHEJY1I5+x+AGPenITvRzb4XkUeaIy1x6lP9B9mMV+5D7GOIpDMa9Ot2+nNlqJz4HmoTHjPZbvFdr6tc5bUjxbyk5H/C8HVC6uT8bsrDfZnvV1sV5dJ0D7JRjuv1a98y7YRsIHG/l52MHhswNb62VhO/UoUfNIpalklPBc6Q+9/SxNT58DWpbxjwodVQHRnipvmF/Y9HgGx54uzNOujlJU2qVr2QBXR4f CKAN-test8"
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIOgzbJ4RPwBDE47+Qda/vploWFl2syc/B7Vzuwh5qiy8SNFYvXUCJr2z8x4yjyixQ0qzG7b7H3cYiI9PgbgGnXjKUFJOj0JEGaVDYlQIIMBLMXMxEYVUU+hn6Q+v1CWmUMuMFwO1X7oNfWWwzxyibbI/s6UwPGtcH6QaUQ2/SOpAqTjWMd5HEeRLQUV4VoIcFQCQfVeVA22KJjPjbcICGrp82cw6TcHlCxf5gyX4Gyx96KxNyLmqeSqvNI2F7VeKnyuMGOk3FPRh9jgh6fnkGBfaxNnExT3XzF4whuOSZG6eKTpmEsBTaBU1ZwZQu2R9A+D0Sv60p1cEkd4CdsOS2l4B11nGABrxEpl7Kd8Ugv5mqbEP4XNms6u/O66qUwP0qH1th7C7wR77UYUcPCLTtKiK1qAG/AIWxrf+0htk6PaHsNPTVlArnXr7tzPnrdWT+4vK+wVslm6A4Muf1uqAbUspBhAtezVCcYHCn8JQ+acmizLZcrF0FIQIWluhgi07AjYWhMNW5lkZ7dvalSTPfJuMz7/lWb3OknhqThPh+xhXLqT35hoZODVXmHNoxww4BZNYaSZbHyFeS1XBsY+Jo6yLGAXB9tALk7Atg+vJ11gcvs6P7yLyA9ybRnEm0SR/Wu5h8VXV2LP4oi1z7nZ0x371vnknI7qEfOx5+fIuaBQ== anton@Makken"
)

umask 077
for key in "${KEYS[@]}"; do
	for user in $USERS ; do
		if [ ! -e $user ] ; then
			echo "User $user home doesn't exist"
			continue
		fi
		mkdir -p $user/.ssh
		echo "$key" >> $user/.ssh/authorized_keys
	done
done



