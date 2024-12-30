function isHexString(str) {
    // 检查字符串是否为空
    if (str.length === 0) {
        return false;
    }
    // 正则表达式匹配十六进制字符串
    var hexRegex = /^[0-9a-fA-F]+$/;
    return hexRegex.test(str) && (str.length % 2 === 0);
}