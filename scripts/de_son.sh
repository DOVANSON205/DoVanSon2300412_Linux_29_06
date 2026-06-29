#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
    echo "Vui long chay script bang quyen root."
    exit 1
fi

BAITAP="/root/baitap"
DSUSER="${BAITAP}/dsuser"
PASSWORD="123456"

title() {
    printf '\n========== %s ==========\n' "$1"
}

add_user() {
    local user_name="$1"
    local group_name="$2"

    if id "${user_name}" >/dev/null 2>&1; then
        usermod -g "${group_name}" "${user_name}"
    else
        useradd -m -g "${group_name}" "${user_name}"
    fi

    echo "${user_name}:${PASSWORD}" | chpasswd
}

title "Cau 1: Tao thu muc /root/baitap"
mkdir -p "${BAITAP}"
ls -ld "${BAITAP}"

title "Cau 2: Xem /etc/passwd"
awk -F: '$3 < 1000 { count++ } END { print "So user he thong:", count + 0 }' /etc/passwd
awk -F: '$3 == 100 { print "User co UID=100:", $1 }' /etc/passwd

title "Cau 3: Ghi user UID=100 va GID=100 vao dsuser"
awk -F: '$3 == 100 && $4 == 100 { print $1 }' /etc/passwd > "${DSUSER}"
echo "So user UID=100, GID=100: $(wc -l < "${DSUSER}")"
cat "${DSUSER}"

title "Cau 4: Xem /etc/group"
awk -F: '$3 < 1000 { count++ } END { print "So nhom he thong:", count + 0 }' /etc/group

title "Cau 5: Tao nhom"
groupadd -f hocvien
groupadd -f admin
groupadd -f user
getent group hocvien admin user

title "Cau 6: Tao user va dat mat khau"
add_user hv1 hocvien
add_user hv2 hocvien
add_user hv3 hocvien
add_user user1 user
add_user user2 user
id hv1
id hv2
id hv3
id user1
id user2

title "Cau 7: Huy user hv3"
if id hv3 >/dev/null 2>&1; then
    userdel -r hv3
fi

title "Cau 8: Cap quyen 640 cho dsuser"
chmod 640 "${DSUSER}"
ls -l "${DSUSER}"

title "Cau 9: Dat umask 027 va tao mau"
umask 027
touch "${BAITAP}/file_umask"
mkdir -p "${BAITAP}/dir_umask"
ls -l "${BAITAP}/file_umask"
ls -ld "${BAITAP}/dir_umask"

title "Cau 10: User1 doc dsuser"
su - user1 -c "cat ${DSUSER}" || echo "user1 khong doc duoc dsuser."
