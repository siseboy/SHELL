#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# --------------------------------------------------------------
#	系统: ALL
#	项目: 蓝奏云上传文件
#	版本: 1.0.3
#	作者: XIU2
#	官网: https://shell.xiu2.xyz
#	项目: https://github.com/XIU2/Shell
# --------------------------------------------------------------

USERNAME="XXX" # 蓝奏云用户名
COOKIE_PHPDISK_INFO="XXX" # 替换 XXX 为 Cookie 中 phpdisk_info 的值
COOKIE_YLOGIN="XXX" # 替换 XXX 为 Cookie 中 ylogin 的值
TOKEN="XXX" # 微信推送链接 Token，可选

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"
HEADER_CHECK_LOGIN="User-Agent: ${UA}
Referer: https://up.woozooo.com/mydisk.php?item=files&action=index&u=${USERNAME}
Accept-Language: zh-CN,zh;q=0.9"

URL_ACCOUNT="https://pc.woozooo.com/account.php"
URL_UPLOAD="https://up.woozooo.com/fileup.php"

INFO="[信息]" && ERROR="[错误]" && TIP="[注意]"

# 检查是否已登录
_CHECK_LOGIN() {
	if [[ "${COOKIE_PHPDISK_INFO}" = "" || "${COOKIE_PHPDISK_INFO}" = "XXX" ]]; then
		_NOTICE "ERROR" "请指定 Cookie 中 phpdisk_info 的值！"
	fi
	if [[ "${COOKIE_YLOGIN}" = "" || "${COOKIE_YLOGIN}" = "XXX" ]]; then
		_NOTICE "ERROR" "请指定 Cookie 中 ylogin 的值！"
	fi

	HTML_CHECK_LOGIN=$(curl -s --http1.1 -b "ylogin=${COOKIE_YLOGIN};phpdisk_info=${COOKIE_PHPDISK_INFO}" -H "${HEADER_CHECK_LOGIN}" "${URL_ACCOUNT}"|grep "登录")
	[[ ! -z "${HTML_CHECK_LOGIN}" ]]  && _NOTICE "ERROR" "Cookie 已失效，请更新！"
}

# 上传文件
_UPLOAD() {
	[[ $(du "${NAME_FILE}"|awk '{print $1}') -gt 100000000 ]] && _NOTICE "ERROR" "${NAME}文件大于 100MB！"
	HTML_UPLOAD=$(curl --connect-timeout 120 -m 5000 --retry 2 -s -b "ylogin=${COOKIE_YLOGIN};phpdisk_info=${COOKIE_PHPDISK_INFO}" -H "${URL_UPLOAD}" -F "task=1" -F "id=WU_FILE_0" -F "folder_id=${FOLDER_ID}" -F "name=${NAME}" -F "upload_file=@${NAME_FILE}" "${URL_UPLOAD}"|grep '\\u4e0a\\u4f20\\u6210\\u529f')
	[[ -z "${HTML_UPLOAD}" ]] && _NOTICE "ERROR" "${NAME}文件上传失败！"
	echo -e "${INFO} 文件上传成功！[$(date '+%Y/%m/%d %H:%M')]"
}

# 消息推送至微信
_NOTICE() {
	PARAMETER_1="$1"
	PARAMETER_2="$2"
    if [[ "${TOKEN}" != "" && "${TOKEN}" != "XXX" ]]; then
	    # 微信推送 Server酱 https://sc.ftqq.com/3.version
	    #wget --no-check-certificate -t2 -T5 -4 -U "${UA}" -qO- "https://sc.ftqq.com/${TOKEN}.send?text=${PARAMETER_1}${PARAMETER_2}"
	    # 微信推送 pushplus http://pushplus.hxtrip.com/
	    wget --no-check-certificate -t2 -T5 -4 -U "${UA}" -qO- "http://pushplus.hxtrip.com/customer/push/send?token=${TOKEN}&title=${PARAMETER_1}&content=${PARAMETER_2}"
    fi
    if [[ ${PARAMETER_1} == "INFO" ]]; then
		echo -e "${INFO} ${PARAMETER_2} [$(date '+%Y/%m/%d %H:%M')]"
	else 
		echo -e "${ERROR} ${PARAMETER_2} [$(date '+%Y/%m/%d %H:%M')]"
	fi
	exit 1
}

NAME="$1" # 文件名
NAME_FILE="$2" # 文件路径
FOLDER_ID="$3" # 上传文件夹ID
if [[ -z "${NAME}" ]]; then
	echo -e "${ERROR} 未指定文件名！" && exit 1
elif [[ -z "${NAME_FILE}" ]]; then
	echo -e "${ERROR} 未指定文件路径！" && exit 1
elif [[ -z "${FOLDER_ID}" ]]; then
	echo -e "${ERROR} 未指定上传文件夹ID！" && exit 1
fi
_CHECK_LOGIN
_UPLOAD