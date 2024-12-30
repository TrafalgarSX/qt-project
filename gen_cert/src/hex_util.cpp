#include <hex_util.h>
#include <cstdint>
#include <string>
#include <vector>

std::string bytesToHexString(const std::vector<uint8_t> buf, char sep) {
  return bytesToHexString(buf.data(), buf.size(), sep);
}

std::string bytesToHexString(const uint8_t *buf, int len, char sep) {
  std::string hexString;
  static const char hexdig[] = "0123456789ABCDEF";
  int hasSep = sep == '\0' ? 0 : 1;

  if (buf == nullptr || len <= 0) {
    return hexString;
  }

  hexString.reserve(len * (2 + hasSep));

  int i = 0;
  const uint8_t *p = buf;
  for (; i < len; i++, p++) {
    hexString += hexdig[(*p >> 4) & 0xf];
    hexString += hexdig[*p & 0xf];
    if (hasSep) {
      hexString += sep;
    }
  }

  return hexString;
}

// hexCharToByte converts a hex character to its integer value.
static uint8_t hexCharToByte(char ch) {
  if (ch >= '0' && ch <= '9') {
    return ch - '0';
  } else if (ch >= 'A' && ch <= 'F') {
    return ch - 'A' + 10;
  } else if (ch >= 'a' && ch <= 'f') {
    return ch - 'a' + 10;
  } else {
    return 0;
  }
}

std::shared_ptr<uint8_t> hexStringToBytes(const std::string &hexString, int *outLen, char sep) {
  std::shared_ptr<uint8_t> buf;
  int len = 0;
  int hasSep = sep == '\0' ? 0 : 1;

  if (hexString.empty()) {
    return buf;
  }

  len = hexString.length() / (2 + hasSep);
  buf = std::shared_ptr<uint8_t>(new uint8_t[len], std::default_delete<uint8_t[]>());

  if (buf == nullptr) {
    return buf;
  }

  int i = 0;
  int j = 0;
  for (; i < len; i++, j += 2 + hasSep) {
    buf.get()[i] =
        (hexCharToByte(hexString[j]) << 4) | hexCharToByte(hexString[j + 1]);
  }

  if (outLen != nullptr) {
    *outLen = len;
  }

  return buf;
}

std::vector<uint8_t> hexStringToBytes(const std::string &hexString, char sep) {
  std::vector<uint8_t> buf;
  int len = 0;
  int hasSep = sep == '\0' ? 0 : 1;

  do {
    if (hexString.empty()) {
      break;
    }
    len = hexString.length() / (2 + hasSep);
    buf.reserve(len);

    int i = 0;
    int j = 0;
    for (; i < len; i++, j += 2 + hasSep) {
      buf.push_back((hexCharToByte(hexString[j]) << 4) |
                    hexCharToByte(hexString[j + 1]));
    }

  } while (0);

  return buf;
}
