#!/usr/bin/env bash
set -euo pipefail

BAITAP_DIR="/root/baitap"
DSUSER_FILE="${BAITAP_DIR}/dsuser"
PASSWORD="123456"

require_root() {
    if [ "${EUID}" -ne 0 ]; then
        echo "Vui long chay script bang quyen root."
        exit 1
    fi
}

print_title() {
    printf '\n========== %s ==========\n' "$1"
}

ensure_group() {
    local group_name="$1"

    if getent group "${group_name}" >/dev/null; then
        echo "Nhom ${group_name} da ton tai."
    else
        groupadd "${group_name}"
        echo "Da tao nhom ${group_name}."
    fi
}

ensure_user() {
    local user_name="$1"
    local primary_group="$2"

    if id "${user_name}" >/dev/null 2>&1; then
        usermod -g "${primary_group}" "${user_name}"
        echo "Nguoi dung ${user_name} da ton tai, cap nhat nhom chinh la ${primary_group}."
    else
        useradd -m -g "${primary_group}" "${user_name}"
        echo "Da tao nguoi dung ${user_name} trong nhom ${primary_group}."
    fi

    echo "${user_name}:${PASSWORD}" | chpasswd
}

cau_1() {
    print_title "Cau 1: Tao thu muc baitap trong home cua root"
    mkdir -p "${BAITAP_DIR}"
    ls -ld "${BAITAP_DIR}"
}

cau_2() {
    print_title "Cau 2: Kiem tra /etc/passwd"
    local system_user_count
    local uid_100_users

    system_user_count="$(awk -F: '$3 < 1000 { count++ } END { print count + 0 }' /etc/passwd)"
    uid_100_users="$(awk -F: '$3 == 100 { print $1 }' /etc/passwd)"

    echo "So nguoi dung do he thong tao ra UID < 1000: ${system_user_count}"
    if [ -n "${uid_100_users}" ]; then
        echo "Nguoi dung co UID=100:"
        echo "${uid_100_users}"
    else
        echo "Khong co nguoi dung nao co UID=100."
    fi
}

cau_3() {
    print_title "Cau 3: Ghi nguoi dung UID=100, GID=100 vao dsuser"
    mkdir -p "${BAITAP_DIR}"
    awk -F: '$3 == 100 && $4 == 100 { print $1 }' /etc/passwd > "${DSUSER_FILE}"

    local matched_count
    matched_count="$(wc -l < "${DSUSER_FILE}")"
    echo "So nguoi dung co UID=100 va GID=100: ${matched_count}"
    echo "Noi dung tep ${DSUSER_FILE}:"
    cat "${DSUSER_FILE}"
}

cau_4() {
    print_title "Cau 4: Kiem tra /etc/group"
    local system_group_count
    system_group_count="$(awk -F: '$3 < 1000 { count++ } END { print count + 0 }' /etc/group)"
    echo "So nhom do he thong tao ra GID < 1000: ${system_group_count}"
}

cau_5() {
    print_title "Cau 5: Tao cac nhom hocvien, admin, user"
    ensure_group "hocvien"
    ensure_group "admin"
    ensure_group "user"
}

cau_6() {
    print_title "Cau 6: Tao nguoi dung va dat mat khau"
    ensure_user "hv1" "hocvien"
    ensure_user "hv2" "hocvien"
    ensure_user "hv3" "hocvien"
    ensure_user "user1" "user"
    ensure_user "user2" "user"
}

cau_7() {
    print_title "Cau 7: Huy nguoi dung hv3"
    if id "hv3" >/dev/null 2>&1; then
        userdel -r "hv3"
        echo "Da huy nguoi dung hv3."
    else
        echo "Nguoi dung hv3 khong ton tai."
    fi
}

cau_8() {
    print_title "Cau 8: Cap quyen 640 cho dsuser"
    touch "${DSUSER_FILE}"
    chmod 640 "${DSUSER_FILE}"
    ls -l "${DSUSER_FILE}"
}

cau_9() {
    print_title "Cau 9: Thiet lap quyen mac dinh bang umask 027"
    umask 027

    local sample_file="${BAITAP_DIR}/taptin_umask"
    local sample_dir="${BAITAP_DIR}/thumuc_umask"

    rm -f "${sample_file}"
    rm -rf "${sample_dir}"
    touch "${sample_file}"
    mkdir "${sample_dir}"

    echo "Quyen tap tin moi:"
    ls -l "${sample_file}"
    echo "Quyen thu muc moi:"
    ls -ld "${sample_dir}"
}

cau_10() {
    print_title "Cau 10: Dang nhap user1 va truy cap dsuser"
    if ! id "user1" >/dev/null 2>&1; then
        echo "Nguoi dung user1 chua ton tai. Hay chay Cau 6 truoc."
        return
    fi

    if su - "user1" -c "cat ${DSUSER_FILE}"; then
        echo "user1 doc duoc tep dsuser."
    else
        echo "user1 khong doc duoc tep dsuser do khong co quyen phu hop."
    fi
}

main() {
    require_root
    cau_1
    cau_2
    cau_3
    cau_4
    cau_5
    cau_6
    cau_7
    cau_8
    cau_9
    cau_10
}

main "$@"
